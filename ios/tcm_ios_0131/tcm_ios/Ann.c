//
//  Ann.c
//  tcm_ios
//
//  Created by jurng chen su on 2025/10/23.
//
// copy + modify from run_once.c
// ann net data file --> load into memory --> send PTR & call me
// 原始的 PureBasic 神經細胞的值被限制在正整數 0 至 99 之間 (8-bit 有號數)
// 原始的 PureBasic 神經細胞的神經鍵值被限制在整數 -128 至 +127 之間 (8-bit 有號數)
// 原始的 PureBasic 為了縮小檔案, 每一個神經鍵值僅用 1 byte 儲存 (8-bit 有號數), 在此須轉成 int (32-bit 有號數) 方便 32/64 位元處理器運算

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char buff[512];
char sCRLF[3] = { 13, 10, 0 };
// char sComma[3] = { 0xa1, 0x42, 0};  // "、"
void debug_Say(char *s) {  printf("%s", s);  }
void hex_dump(void *p, int len);
void show_str(int i, int n, char *s);
int trim(char *s);

struct my_message { // 訊息儲存架構
    int  n_max_chars;   // 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
    int  n_lines;       // 實際訊息有幾行 (每則訊息上限 8 行, 單一訊息最多 8 * 256 = 2048 字元)
    char *str[8];       // 實際訊息儲存在此 (字串指標)
};

struct  my_message  *my_mesg;   // 訊息陣列 (msg_count 為其數量)
int     group_score[6];     // 六大證型目前得到幾分
int     msg_max = 0;        // 訊息字串數上限, 範圍: 0 至 ??
int     msg_count = 0;      // 訊息字串數, 範圍: 0 至 255  (目前固定為 32)
int     firing_level = 69;  // 神經細胞啟動值, 範圍: 0 至 99
int     input_count;        // 輸入層神經細胞數 (上限: 256)
int     middle_count;       // 中間層神經細胞數 (上限: 512)
int     output_count;       // 輸出層神經細胞數 (上限: 256)
int     cells_input[256];   // 輸入層神經細胞陣列 (上限: 256)
int     cells_middle[512];  // 中間層神經細胞陣列 (上限: 512)
int     cells_output[256];  // 輸出層神經細胞陣列 (上限: 256)
int     net_upper[256][512];    // 輸入層 --> 中間層 神經鍵值 (加權值)
int     net_lower[512][256];    // 中間層 --> 輸出層 神經鍵值 (加權值)
char    ans[2048];        // 單次暫時輸出文字訊息用 (單一訊息最多 8 * 256 = 2048 字元)
// -------
int  Find_CR(char *p, int loc);    // 從 p[loc] 處開始找換行字元 CR (13)
int  get_msg_str(int msg_id);
void load_full_data(char *ptr);
void load_data(char *ptr);
void run_once(void);
// -------
// char *fname = "an100100.bin";    // /data/data/com.sjc.txstroke/files/
char *sbuf[256];
long f_len, ofs;
char *base_ptr;
char *ptr = NULL, *old_ptr = NULL;

const char *ret_six_answer(void)
{   // 傳回 six group ANN 結果字串
    // dump [ptr + 256] --> offset 0: 1st word = 訊息長度，   offset 2: 2nd word = 輸出細胞數
    // offset 32: 32th byte = 輸出層的值 byte array [輸出細胞數], 然後緊接著是訊息！
    unsigned char *pb;
    int output_cnt;
    
    pb = (unsigned char *) (ptr + 256);
    output_cnt = pb[2] + (pb[3] << 8);
    hex_dump(ptr + 288 + output_cnt, 32);
    return(ptr + 288 + output_cnt); // + output_count
}

int six_main(const char *arg, const char *scores)
{    // 傳回 0 代表成功, 傳回 1 代表失敗. arg 是檔案路徑, scores[6] 是六大證型得分
FILE    *fhnd;
long    len;
int     i;

if (old_ptr == NULL) free(old_ptr);     // 先釋放舊資料區
ptr = malloc(131072);
memset(ptr, 0, 131072);
base_ptr = ptr;        // debug_Say("in main #52..");    debug_Say(arg);
if (! my_mesg) {
    my_mesg = malloc(65536);
    msg_max = 65536 / sizeof(struct my_message);
    }
memset(my_mesg, 0, 65536);
printf("%s\n", arg);
fhnd = fopen(arg, "rb");
if (! fhnd) { printf("Open ANN data file failed !\n");  return(1); }        // 傳回 1 代表失敗
fseek(fhnd, 0, 2);
len = ftell(fhnd);
fseek(fhnd, 0, 0);
len = fread(ptr, 1, len, fhnd);
fclose(fhnd);        f_len = len;
printf("read %ld bytes OK. 檔案開頭標記 --> %s\n", len, ptr);
load_data(ptr);
debug_Say("\nAnn.c #94 six_main() 將要執行 run_once()\n");    // 執行單一次神經網路運算 (無回溯, no feedback)
// 清除三層神經細胞為 0
for (i = 0; i < 256; i ++) {
    cells_input[i] = 0;    // 清除輸入層神經細胞為 0
    cells_output[i] = 0;    // 清除輸出層神經細胞為 0
    }
for (i = 0; i < 512; i ++) cells_middle[i] = 0;        // 清除中間層神經細胞為 0

// 按照 ANNxxxxxx 來填分數測試 !
// for (i = 0; i < 6; i++) ptr[256 + i] = scores[i];
// group_score[0] = arg[256];    // 90;
// group_score[1] = arg[257];    // 0;
// group_score[2] = arg[258];    // 0;
// group_score[3] = arg[259];    // 90;
// group_score[4] = arg[260];    // 0;
// group_score[5] = arg[261];    // 0;
for (i = 0; i < input_count; i ++) {
    cells_input[i] = scores[i];    // 填入輸入層的值
    printf("輸入 cell# %d, 數值 = %d\n", i + 1, cells_input[i]);
}

run_once();

debug_Say("神經網路程式順利執行, 返回 !");
old_ptr = ptr;  // 舊記憶體必須釋放，否則會造成堆積錯誤 !
ptr = (char *) &arg[0];
ptr[258] = (unsigned char) output_count;    // 傳回輸出層的神經細胞數
memset(ptr + 259, 0, 128);
ofs = 32 + output_count;    // 跳過內部保留訊息長度
//    return(0);    // 傳回 0 代表成功
for (i = 0; i < output_count; i++) {
    ptr[288 + i] = (unsigned char) cells_output[i];    // 填入輸出層的值
    if (cells_output[i] > firing_level) {
        len = get_msg_str(input_count + i);    // 取得單一訊息到 ans[], 長度放在 len
        hex_dump(ans, 16);  // 目前尾端已無 0D or 0A !
        // 沒有結果尾端會得到 0D 0A, 有結果尾端會得到 0D 0D 0A
        if ((ofs + len) > 2048) {
            len = 2048 - ofs;    debug_Say("錯誤: 訊息總長度加上內部保留訊息長度太長 ! 超過 2048 字元 !");
            }
        memcpy(ptr + 256 + ofs, ans, len + 1);
        ofs += len;
        }
    }
ofs = ofs - 32 - output_count;    // 此為真正訊息總長度 (= 2048 - 32 - output_count)
ptr[256] = ofs & 255;        ptr[257] = (ofs >> 8) & 255;    // 紀錄訊息總長度 (< 2048 字元)
printf("真正訊息總長度 = %ld, output_count = %d, 訊息:[%s]\n", ofs, output_count, ptr + 288 + output_count);
hex_dump(ptr + 256, 64);
// free(ptr);
return(0);    // 傳回 0 代表成功
}

// -------
int Find_CR(char *p, int loc)
{ // 從 p[loc] 處開始找換行字元 CR (13)
while (p[loc]) {
    if (p[loc] == 13) return(loc);        // 找到了 !
    loc ++;
    }
return(0);    // 沒找到
}

// -------
int get_msg_str(int msg_id)
{
struct my_message    *msg;
int    i;

if (msg_id >= msg_count) return(0);        // 超過上限範圍 !
msg = my_mesg + msg_id;
// 直接存到 ans[2048] --> 最多取 8 行, 每一行上限 256 字元 (8 * 256 = 0x800)
ans[0] = 0;
for (i=0;i < msg->n_lines; i ++) { // 最多取 8 行 (儘量用 Big-5 碼, 儘量勿用 UTF-8, 因為會參雜 < 32 的控制字元)
    if (strlen(msg->str[i]) > 0) {  hex_dump(msg->str[i], 16);
        strcat(ans, msg->str[i]);    trim(ans);
        strcat(ans, ", ");    // sComma  hex_dump(ans, 16);    debug_Say(ans);
        }
    }    // msg->str[i] 的尾端會有一個 0D 00
return(strlen(ans));    // 傳回 ans 裡面的文字總長度
}

// -------
void load_full_data(char *ptr)
{ // 直接讀取整個 ann net data file, 程式自動讀取 (ANNData.BIN, 71 Kb)
int *pI;
unsigned char *pB;

ptr = ptr + 128;    // 最開頭的 128 bytes 為文字說明, 略過 !
pI = (int *) ptr;
input_count = *pI;    pI ++;        // 取得輸入層神經細胞數 (上限: 256)
middle_count = *pI;    pI ++;        // 取得中間層神經細胞數 (上限: 512)
output_count = *pI;    pI ++;        // 取得輸出層神經細胞數 (上限: 256)
}

// -------
void load_data(char *ptr)
{ // 直接讀取整個 ann compact net data file (ANN******.BIN), 程式自動讀取
struct my_message    *msg;
int *pI;        // 32-bit PTR
unsigned short *pW;    // 16-bit PTR
unsigned char *pB;    //  8-bit PTR
char *tmp;
int    crloc, i, j, last_cr, max_char_num, part_len, slen;

hex_dump(ptr, 512);
ptr = ptr + 32;        // 最開頭的 32 bytes 為文字說明, 略過 !
pW = (unsigned short *) ptr;
input_count = *pW;    pW ++;        // 取得輸入層神經細胞數 (上限: 256)
middle_count = *pW;    pW ++;        // 取得中間層神經細胞數 (上限: 512)
output_count = *pW;    pW ++;        // 取得輸出層神經細胞數 (上限: 256)
firing_level = *pW;    pW ++;        // 取得 firing_level 值 (範圍: 0 至 99)
msg_count = *pW;    pW ++;        // 取得訊息字串數 (目前固定為 32)
printf("神經細胞數: 輸入層= %d, 中間層= %d, 輸出層= %d, 閥值= %d, 訊息字串數= %d\n", input_count, middle_count, output_count, firing_level, msg_count);
ptr = ptr + 16;     // 跳到 檔案位置 48 (0x30)
// ------- 讀取 輸入層 --> 中間層的神經網路加權值 (weights) = (input_count * middle_count) bytes -------
for (i = 0;i < input_count;i ++) {
    for (j = 0;j < middle_count; j ++) {
        net_upper[i][j] = *ptr;
        ptr = ptr + 1;
        } // for: j
    } // for: i
// ------- 讀取 中間層 --> 輸出層的神經網路加權值 (weights) = (middle_count * output_count) bytes -------
for (i = 0;i < middle_count; i ++) {
    for (j = 0;j < output_count; j ++) {
        net_lower[i][j] = *ptr;
        ptr = ptr + 1;
        } // for: j
    } // for: i
printf("訊息擺放的起點 offset = 0x%x bytes\n", (int) (ptr - base_ptr));  // return;
// ------- 讀取訊息 -------
msg = my_mesg;
for (i = 0; i < msg_count; i ++) {    // 清除整個訊息儲存架構 (訊息字串數 msg_count 目前固定為 32)
    msg->n_max_chars = 0;    // 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
    msg->n_lines = 0;    // 實際訊息有幾行 (每則訊息上限 8 行)
    for (j = 0; j < 8;j ++) {
        if (! msg->str[j]) {
            msg->str[j] = malloc(256);    // 預借 256 bytes 給字串 (顯示用)
            memset(msg->str[j], 0, 256);  // 預先清除
            }
        }
    last_cr = -1;
    max_char_num = 0;
    pW = (unsigned short *) ptr;    ptr = ptr + 2;
    slen = *pW;    // slen = 此為字串實佔長度
    printf("slen = %d\n", slen);
    tmp = ptr;    // 記住此開頭位置
    if (slen > 0) {    // 有訊息內容
        // show_str(i, slen, tmp);
        ptr = ptr + slen;    // 讓 ptr 指到下一字串開頭
        for (j = 0; j < 8;j ++) { // 最大掃描紀錄 8 行 (成為單一訊息)
            crloc = Find_CR(tmp, last_cr + 1);
            if (crloc > 0) {  // 有找到 chr(13) = CR 換行分割標記
                // printf("j = %d, crloc = %d\n", j, crloc);
                part_len = crloc - last_cr;    // 此小段字串的長度
                memcpy(msg->str[j], tmp + last_cr + 1, part_len + 1);    // strncpy
                // hex_dump(msg->str[j], part_len + 1);
                if (max_char_num < part_len) max_char_num = part_len;
                last_cr = crloc;
                }
            else    { // 沒有找到 chr(13) = CR 換行分割標記
                // printf("j = %d, slen = %d\n", j, slen);
                if (max_char_num == 0) max_char_num = slen;    // 僅剩單行訊息
                msg->n_lines = j + 1;            // 更新此訊息實際行數 (最後一行可能是空的 !)
                msg->n_max_chars = max_char_num;    // 更新此訊息最長的字串小段長度
                break;    // 已經沒有 CR 換行分割標記, 提前結束 (for j)
                }
            } // for: j
        } // if: slen
    // printf("訊息 %d: 實際行數= %d, 最長的字串小段長度= %d bytes.\n", i, msg->n_lines, msg->n_max_chars);
    msg ++;        // 繼續檢查下一訊息
    } // for: i
printf("成功載入類神經網路資料 !   Final ofs = 0x%x (處理了 %d bytes)\n", (int) (ptr - base_ptr), (int) (ptr - base_ptr));
debug_Say("成功載入類神經網路資料 !");
}
// -------
void run_once(void)
{
int    i, j;

// ------- 檢查輸入層神經細胞 --------
for (i = 0;i < input_count; i ++) { // 從輸入層神經細胞開始檢查
    if (cells_input[i] > firing_level) { // 大於此閥值, 代表輸入層神經細胞活化 !
        for (j = 0; j < middle_count; j ++) { // 往中間層處理
            cells_middle[j] = cells_middle[j] + net_upper[i][j];    // 輸入層神經細胞有活化, 此時中間層神經細胞可以得到相對應的神經網路加權值 (weight)
            if (cells_middle[j] > 100) cells_middle[j] = 100;    // 防止超過 100 (上限)
            } // for: j
        } // if: cells_input[i]
    } // for: i
// ------- 檢查中間層神經細胞 --------
for (i = 0;i < middle_count;i ++) { // 從中間層神經細胞開始檢查
    if (cells_middle[i] > firing_level) { // 大於此閥值, 代表中間層神經細胞活化 !
        for (j = 0; j < output_count; j ++) { // 往輸出層處理
            cells_output[j] = cells_output[j] + net_lower[i][j];    // 輸入層神經細胞有活化, 此時中間層神經細胞可以得到相對應的神經網路加權值 (weight)
            if (cells_output[j] > 100) cells_output[j] = 100;    // 防止超過 100 (上限)
            } // for: j
        } // if: cells_middle[i]
    } // for: i
// ---- 收集最終結果 (輸出層神經細胞) ----
/* for (i = 0;i < output_count;i ++) { // 從輸出層神經細胞開始檢查
    printf("輸出層 cell %d = %d\n", i, cells_output[i]);
    if (cells_output[i] > firing_level) { // 大於此閥值, 代表輸出層神經細胞活化 !
        printf("此證型的輸出: %s\n", get_msg_str(6 + i));    // 取得訊息字串 (頭六個字串是六大證型, 故加 6)
        }
    }    */
}

void show_str(int i, int n, char *s)
{
    char stra[256], strb[16];
    unsigned char *pb;
    
    sprintf(stra, "%d: ", i);
    pb = (unsigned char *) s;
    for (i=0; i < n;i ++) {
        sprintf(strb, "%02X ", pb[i]);
        strcat(stra, strb);
    }
    printf("%s\n", stra);
}


int trim(char *s)
{
int        len;
char    c, spc;

    len = (int) strlen(s) - 1;
    if (len < 0) return 0;
    do    {
        c = s[len];        spc = 0;
        if ((c == 32) || (c == 9))  { spc = 1;  s[len] = 0;    }    // SPACE, TAB
        if ((c == 10) || (c == 13)) { spc = 1;  s[len] = 0;    }    // CR, LF
        len --;
    } while (spc);
    do    {
        c = *s++;
        if ((c == 32) || (c == 9)) continue;    //  SPACE, TAB, CR, LF
        if ((c == 10) || (c == 13)) continue;   //  CR, LF
        s --;    strcpy(buff, s);    strcpy(s, buff);    c = 0;
    } while (c != 0);    // ** bug: trim
    return((int) strlen(s));
}
