//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// ----- in myWork.c -----
void set_HOME_path(const char *str);    // <-- cStringPointer (不可用 char *)
const char *ret_answer(void);           // 傳回結果字串

// ----- in Ann.c -----
int six_main(const char *arg, const char *scores);  // arg 是檔案路徑, scores[6] 是六大證型得分
const char *ret_six_answer(void);       // 傳回 six group ANN 結果字串
