# 基於情緒分析以實現個人化影像風格轉換之研究
## How-Are-You

###### tags: `NTUE_Project`

---

[TOC]

---

## 第一章　前言
### 第一節　研究背景
近年來，以社群媒體為主等新興媒體如雨後春筍般接連出現，提供人們快速、即時且方便的管道，讓大家不僅能分享各自的生活近況，也能抒發生活壓力。許多公司也嗅到了這波趨勢，紛紛推出自家的社群媒體應用程式，以滿足使用者的各種需求。目前較為人知的社群媒體，在使用者發布貼文時提供多種濾鏡對多媒體檔案進行加工，大多僅針對明暗變化、色彩飽和度及物體輪廓修飾等基本調整，如Instagram。同時，傳統的社群媒體較強調圖片轉換的即時性，因此在圖片的處理上通常是針對整張圖片進行處理，無法針對單一區域或是單一像素去進行轉換，效果十分有限。
### 第二節　研究目的
本研究結合文本情緒統計概念，以Flask為基礎，開發一款個人化影像風格轉換應用程式，如圖1.1所示。其中，Flask是一款使用Python語言撰寫的Web框架，具有高靈活性與輕量兩大特色[1]。其便利性除了可應用於網站服務外，也提供了手機程式開發者建立API服務。首先，本研究將會藉由情緒分析模組，將使用者的文字歸類至某一種常見情緒。接著，針對不同的情緒將會給予數張適合的風格影像(Style Image)作為轉換樣本，在Web Server上轉換完畢後透過API上傳至雲端空間，再顯示於使用者的行動裝置上。最後，使用者可以在應用程式中調整文字大小、顏色及顯示位置等，也可決定是否連結其他社群媒體，分享生活近況、抒發情緒。
## 第二章　文獻探討
### 第一節　Flutter
Flutter是一個Google基於Dart語言研發的開源UI框架，可以進行跨平台開發，只要撰寫一份程式碼就能夠在Android、iOS、Windows、MacOS及Web等多個平台上執行，而Dart是Google主導開發的程式語言，主要應用於前端介面設計[2]。Flutter內建了豐富且精美的元件庫，以及流暢連貫的動畫設計，再加上熱重載(Hot Reload)的功能，藉由它將開發人員更改的程式碼加入正在執行的程序中，故可以即時進行測試、新增及修改功能並快速地修復錯誤，使程式在開發過程中能夠更加便利與提升效率[2][3]。
### 第二節　Style Transfer
Style Transfer是一種以卷積神經網路(CNN)為基礎的方法[4]。我們可以將一張圖片的資訊簡單區分成內容(Content)與風格(Style)兩種。內容隨著layer數逐漸提高，CNN會逐漸捨棄掉圖片中一些微小細節，僅保留主要物體的輪廓。此外，由於在一幅作品中作者的風格會呈現一致，因此可藉由比對不同Filter的結果來判斷是否為風格特徵，如圖2.1。另一種方法則是Fast Style Transfer，此方法訓練速度較快且產生的模型較小，但需要大量的資料作為訓練集且一個模型僅支援一種風格[5]。而近年來Google Tensorflow提出另一種改良方式支援Real-Time轉換[6]，僅需一個模型即可實現多種風格轉換，因此本研究將以此模型[7]設計一款手機應用程式。
## 第三章　研究方法
在本研究開發之應用程式中，使用了兩個API服務，如圖3.1所示。其一為Imgur API[8]，用以儲存圖片，並讓用戶端與伺服器端能以網址的方式傳遞該圖檔之資訊；其二則是本研究後端主要功能(之後說明皆以Web Server代稱)，接收用戶拍攝的照片與輸入的文字，並回傳經情緒分析與風格轉換模型之影像結果。其中，Web Server的服務又可分為兩段主要功能，其一為情緒分析，採用Cnsenti文本情緒統計服務[9]；而其二為影像風格轉換，模型則是以Tensorflow Style Transfer服務，對風格影像和內容影像進行計算並生成新的影像。
### 第一節　以Flutter跨平台框架實作用戶端服務
首先說明用戶端，也就是系統前端的部分。應用程式將會在用戶的操作中取得一情緒文本與一圖片，再將該圖片透過Imgur API上傳至Imgur網站取得其image url，最後將代表該圖片的image url與情緒文本交由Web Server取得經過風格轉換之數張圖片的image url，如圖3.2所示。
當用戶開啟應用程式後，會先顯示歡迎動畫，再跳轉至相機畫面，此時用戶可以選擇直接拍攝，或是點擊右下角相簿圖示選擇本機裡的圖片，其中，若是用戶選擇了JPG格式以外的圖片將會觸發提示訊息，如圖3.3所示。
之後用戶可以在框內輸入文字抒發情緒，並在輸入完成後按下「Next」送出。其中，送出的圖片將會先經過Imgur API取得其image url，再將情緒文本與image url交由Web Server進行風格轉換。送出資料後用戶需等待30秒左右的時間(30秒為估計時間，視網路連線狀況與圖片的檔案大小，可能有所誤差)。接著畫面便會出現3至5張經過風格轉換的圖片，用戶可依喜好滑動畫面，並從其中選擇一張進行編輯，如圖3.4所示。
進入編輯畫面後，用戶可從右側工具欄改變文字樣式，並且通過直接拖曳改變文字位置。其中，工具欄由上至下分別為「重置文字位置(左上角)」、「改變文字顏色」、「改變文字大小」、「改變多行文字對齊方式」、「改變文字字型」。最後，編輯完成的圖片會自動存檔至本機，用戶可選擇是否分享至其他社群媒體，如圖3.5所示。
### 第二節　以Python Flask實作應用程式之API服務
本研究使用Python的Flask套件作為backend的Web Server，透過HTTP get、post的方式與用戶端進行聯繫，如圖3.6所示。
在以用戶傳送至Web Server的image url，將上傳至Imgur的圖檔下載至本機後，Web Server首先會將用戶所輸入的文字交給Cnsenti進行文本情緒統計，即對文本中出現的情緒形容詞統計其出現次數，如圖3.7所示。
Cnsenti統計情緒形容詞的分類參考了Dr. Paul Ekman於1972年在《Universals and Cultural Differences in Facial Expressions of Emotions》[10]所提出的人類基本情緒(Anger、Disgust、Fear、Surprise、Happiness、Sadness)，我們將其統計結果最高情緒作為結果回傳值，若最高的情緒統計同時有複數個，將會隨機取其中一種。其次，Web Server會以cnsenti回傳的情緒找出對應的數張風格影像(Style Image)再以用戶所選擇的圖檔作為內容影像(Content Image)，將兩者交由Tensorflow Style Transfer的模型，讓其進行類神經網路影像風格轉換，並回傳數張轉換過的結果影像。最後，Web Server會利用Imgur API上傳結果影像，並將多個影像網址回傳至用戶端，如圖3.8所示。
## 第四章　結果與討論
### 第一節　文字語意分析
呈第三章第二節所述，Cnsenti統計情緒形容詞的分類參考了Dr. Paul Ekman的六大情感，再加入類別「好」對褒義情感作進一步的劃分，主要是針對祝福、相信、讚揚、尊敬等正面情緒，最後總計七種不同的情緒，如表4.1所示。
### 第二節　風格轉換測試
呈第三章第二節所述，Web Server會將內容影像(Content Image)與數張風格影像(Style Image)交給Tensorflow Style Transfer的模型，讓其進行類神經網路影像風格轉換，如表4.2所示。
## 第五章　結論
### 第一節　結論
透過本研究的應用程式即時繪圖運算可產生帶有情緒色彩的風格轉換圖，市面上的產品大多還停留在調整色彩和對比等較為淺層的功能，因為這項技術目前最大的瓶頸是使用者的手機硬體效能，若是將model放入使用者手機內進行風格轉換運算的話，目前已知的缺點就包含了發燙、model容量過大和運行時記憶體空間占用過大的問題。
因此我們在討論後決定將圖片透過Imgur API，以網址的方式傳遞至Web Server，但即便如此還是無法解決轉換結果可能與預期不符的問題，以及運算時間過長。其中，我們也嘗試過利用電腦的GPU運行，也會一下就將GPU的記憶體吃滿。或許在未來，Style Transfer的技術提升和硬體突破後，能有效降低時間複雜度與空間複雜度的演算問題，同時也讓該工具更普及化，在社群軟體中能有更好的表現。
### 第二節　未來展望
目前本研究開發之應用程式提供用戶拍攝照片進行風格轉換，並且分享至外部社群軟體，未來可以再新增類似Instagram限時動態功能，提供用戶之間互相對成品留下私人訊息評論。另外，在2017年時，張榮傑提及了影片的風格轉換，能夠將前景物體和背景分開，並個別進行不同風格的轉換[11]，這也能作為應用程式未來能擴充的功能。
## 參考文獻
1. Armin, R. (2022). Welcome to Flask – Flask Documentation. Flask. https://flask.palletsprojects.com/en/2.2.x/
2. Lin, S. (2020). 行動開發的革命性工具—Flutter. 雲端互動Cloud Interactive. https://www.cloud-interactive.com/tw/insights/whats-revolutionary-about-flutter (Accessed Date: 2021/06/10)
3. 張大偉（2020）。藉由Google Flutter打造一款線上服務。碩士論文。朝陽科技大學，臺中市。https://hdl.handle.net/11296/yj6n4x
4. Gatys, L. A, Ecker, A. S, and Bethge, M. (2015). A Neural Algorithm of Artis-tic Style. Journal of Vision, Vol.36, pp.326. DOI: https://doi.org/10.1167/16.12.326
5. Johnson, J., Alahi, A., and Fei-Fei, L. (2016). Perceptual Losses for Real-Time Style Transfer and Super-Resolution. In: Leibe, B., Matas, J., Sebe, N., Welling, M. (eds) Computer Vision – European Conference on Computer Vision (ECCV 2016), pp.694. DOI: https://doi.org/10.1007/978-3-319-46475-6_43
6. Ghiasi, G., Lee, H., Kudlur, M., Dumoulin, V., and Shlens, J. (2017). Exploring the structure of a real-time, arbitrary neural artistic stylization network. In T.K. Kim, S. Zafeiriou, G. Brostow and K. Mikolajczyk, editors, Proceedings of the British Machine Vision Conference (BMVC 2017), London, pp.114. DOI: https://dx.doi.org/10.5244/C.31.114
7. Google Tensoeflow. (2021) Fast Style Transfer for Arbitrary Styles Tensoeflow. https://www.tensorflow.org/hub/tutorials/tf2_arbitrary_image_stylization (Accessed Date: 2021/08/10)
8. imgur (2022). Imgur API imgur https://apidocs.imgur.com/ (Accessed Date: 2022/08/10)
9. Xu-Dong, D. (2022). Cnsenti. GitHub. https://github.com/hidadeng/cnsenti (Accessed Date: 2022/07/10)
10. Ekman, P., Friesen, W. V., O'Sullivan, M., Chan, A., Diacoyanni-Tarlatzis, I., Heider, K., Krause, R., LeCompte, W. A., Pitcairn, T., & Ricci-Bitti, P. E. (1987). Universals and cultural differences in the judgments of facial expres-sions of emotion. Journal of personality and social psychology, pp. 712. DOI: https://doi.org/10.1037//0022-3514.53.4.712
11. 張榮傑（2017）。基於語義分割之影片風格轉換。碩士論文。國立交通大學，新竹市。https://hdl.handle.net/11296/xf4n7f

---

## Other

* [PDFfile(written report)](https://drive.google.com/file/d/1cHcoVKRSlAyDs-Dvuw_UXaGYZASAaI5C/view?usp=share_link)
* [Canva(poster)](https://www.canva.com/design/DAFSHKhJ6FQ/vrOyeJL0jl9if-jniDTHjA/view?utm_content=DAFSHKhJ6FQ&utm_campaign=designshare&utm_medium=link&utm_source=homepage_design_menu)
* [Canva(PPT)](https://www.canva.com/design/DAFSw4BGxg8/jMHqPqXv83535WT89XUnVg/view?utm_content=DAFSw4BGxg8&utm_campaign=designshare&utm_medium=link&utm_source=publishsharelink)

---

## Author

* [How_Are_You_Backend](https://github.com/seanchang74/How_Are_You_Backend)
    * [seanchang74](https://github.com/seanchang74)、[willieooq](https://github.com/willieooq)
* [How-Are-You](https://github.com/jessie900309/NTUE_How-Are-You)
    * [winnielin17](https://github.com/winnielin17)、[JessieOuO](https://github.com/jessie900309)

