//
//  myWork.c
//  tcm_ios
//
//  Created by jurng chen su on 2025/10/21.
//
// read --> https://developer.apple.com/documentation/swift/importing-objective-c-into-swift
// FileManager.default.currentDirectoryPath = "/"
// URL.currentDirectory() = "file:///"
// print(NSHomeDirectory()) --> 模擬器結果： /Users/happysu/Library/Developer/CoreSimulator/Devices/8D9BC302-0DE1-4F79-B14E-76911B8F31CF/data/Containers/Data/Application/11579689-A558-4D43-AE8A-D8E7E51391AC
// --> 實體手機結果： /var/mobile/Containers/Data/Application/93AF06D9-7B47-4FA7-AC47-80E350768672  (iphone 2020se)
//  print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)) -->
//  模擬器結果： [file:///Users/happysu/Library/Developer/CoreSimulator/Devices/8D9BC302-0DE1-4F79-B14E-76911B8F31CF/data/Containers/Data/Application/767BBD11-0808-4593-B832-1E2EEE1E1DE5/Documents/]
// 基本的目錄
//   NSString *homePath = NSHomeDirectory(); // 根目錄
//   NSString *tmpPath = NSTemporaryDirectory(); // 暫存目錄
// Documents 資料夾
//   NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
//   NSString *documentsPath = [paths objectAtIndex:0];
// <程式根目錄>/Documents/happyman.plist
//   NSString *happymanPath = [documentsPath stringByAppendingPathComponent:@“happyman.plist”];
// 應用程式路徑的取得
//   NSString *appPath = [[NSBundle mainBundle] bundleIdentifier];
//   在終端機打指令：open “路徑"，即可打開該資料夾查看，不過只能用在模擬器，實機上無法作用。
// 某應用程式路徑的取得
// NSString *filePath =  [[NSBundle mainBundle] pathForResource:@"HappyManSettings" ofType:"plist"];

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *home_path;    // 預備了 2048 bytes 來儲存 app 的 HOME 檔案路徑
char *answer;

void set_HOME_path(const char *str)
{
    answer = malloc(2048);
    home_path = malloc(2048);
    strcpy(home_path, str);
    printf("HOME (%ld bytes) 路徑：%s", strlen(home_path), home_path);
}
const char *ret_answer(void)
{   // 傳回結果字串
    strcpy(answer, "\n結果字串\nBye\nDone!\n\n");
    return(answer);
}

void hex_dump(void *p, int len)
{
int        i, j;
unsigned char *pb;
char    s[128], s1[16];

    pb = p;        if (p == NULL) { printf("HexDump: NULL pointer !!");  return; }
    if (len < 1) {  printf("HexDump: length < 1");  return;  }
    s[127] = 0;
    while (len > 0) {
        memset(s, 32, 127);      sprintf(s, "%zx-    ", (size_t) pb);
        for (i = 0, j = 14;i < 16;i ++, j += 3) { sprintf(s1, "%02x", pb[i]);  memmove(s+j, s1, 2); }
        for (i = 0;i < 16;i ++) s[i+64] = ((pb[i] > 31) && (pb[i] < 127)) ? pb[i] : '.';        s[81] = 0;
        printf("%s\n", s);    len -= 16;        pb += 16;
    }
}
