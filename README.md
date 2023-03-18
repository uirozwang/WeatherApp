# WeatherApp  
  
Weather是一款仿官方天氣APP  
  
數據來源：opendata  
定位服務：官方定位SDK  
  
開發環境：Xcode 14.3 beta 3 (14E5215g)  
最低版本：iOS 16.2  
模擬器機型：iPhone 14 Pro Max  
測試機型：iPhone 13 Pro Max  
  
### 主要功能：  
1. 顯示當前城市名稱、溫度、天氣狀況、最高最低氣溫  
2. 每三小時的天氣圖標氣溫  
3. 一週內天氣與溫度上限，並提供線段圖標便於與一週內高低溫對比  
4. 點擊定位按鈕顯示當前位置天氣  
  
### 即將更新：  
1. 多城市儲存功能，並在非搜尋狀態時顯示所有城市大略天氣於搜尋頁面（目前僅能儲存最後查詢的城市  
2. 搜尋功能優化，當前演算法排序不良  
3. 其餘官方APP有提供之天氣資料方塊，例如紫外線指數、體感溫度等  
  
### 已知bug;  
1. 網路狀況不佳時，有機率報錯  
2. 由於opendata的API會提前移除當前天氣資料，例如5點時僅能查詢到6點以後的資料，因此目前是以顯示最新一筆資料為準  
3. 每三小時天氣的collectionView的寬度，目前無法相容其他機型  
4. 已設定常見天氣對應的圖標，部分天氣圖標會在取得資料後補充  
  
PS.兩次切換到彰化市，是因為按下右邊的定位按鈕  

<img src="https://github.com/uirozwang/WeatherApp/blob/main/WeatherApp.gif" alt="your-gif-description" style="max-width: 50px;">
