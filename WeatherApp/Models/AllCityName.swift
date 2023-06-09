//
//  AllCityName.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/24.
//

import Foundation

class AllCityName {
    static let shared = AllCityName()
    var allCityName = [["蘇澳鎮", "頭城鎮", "宜蘭市", "南澳鄉", "羅東鎮", "三星鄉", "大同鄉", "五結鄉", "員山鄉", "冬山鄉", "礁溪鄉", "壯圍鄉"],
    ["龍潭區", "八德區", "龜山區", "大園區", "蘆竹區", "楊梅區", "大溪區", "中壢區", "復興區", "桃園區", "觀音區", "新屋區", "平鎮區"],
    ["峨眉鄉", "寶山鄉", "竹東鎮", "五峰鄉", "竹北市", "尖石鄉", "橫山鄉", "芎林鄉", "北埔鄉", "關西鎮", "新埔鎮", "新豐鄉", "湖口鄉"],
    ["銅鑼鄉", "苗栗市", "頭屋鄉", "南庄鄉", "卓蘭鎮", "泰安鄉", "後龍鎮", "獅潭鄉", "公館鄉", "大湖鄉", "通霄鎮", "西湖鄉", "苑裡鎮", "三義鄉", "頭份市", "三灣鄉", "竹南鎮", "造橋鄉"],
    ["田尾鄉", "埔心鄉", "伸港鄉", "社頭鄉", "秀水鄉", "溪湖鎮", "彰化市", "芳苑鄉", "大村鄉", "和美鎮", "竹塘鄉", "花壇鄉", "二林鎮", "員林市", "線西鄉", "溪州鄉", "永靖鄉", "福興鄉", "二水鄉", "埤頭鄉", "田中鎮", "鹿港鎮", "大城鄉", "埔鹽鄉", "北斗鎮", "芬園鄉"],
    ["草屯鎮", "竹山鎮", "集集鎮", "名間鄉", "國姓鄉", "水里鄉", "南投市", "信義鄉", "埔里鎮", "仁愛鄉", "鹿谷鄉", "中寮鄉", "魚池鄉"],
    ["斗六市", "崙背鄉", "二崙鄉", "林內鄉", "水林鄉", "土庫鎮", "臺西鄉", "西螺鎮", "褒忠鄉", "虎尾鎮", "東勢鄉", "斗南鎮", "麥寮鄉", "莿桐鄉", "大埤鄉", "口湖鄉", "古坑鄉", "四湖鄉", "北港鎮", "元長鄉"],
    ["義竹鄉", "東石鄉", "六腳鄉", "太保市", "水上鄉", "鹿草鄉", "布袋鎮", "竹崎鄉", "朴子市", "中埔鄉", "民雄鄉", "番路鄉", "大林鎮", "梅山鄉", "新港鄉", "阿里山鄉", "溪口鄉", "大埔鄉"],
    ["萬丹鄉", "霧臺鄉", "新園鄉", "麟洛鄉", "泰武鄉", "林邊鄉", "里港鄉", "春日鄉", "佳冬鄉", "高樹鄉", "牡丹鄉", "屏東市", "車城鄉", "內埔鄉", "東港鎮", "枋山鄉", "新埤鄉", "枋寮鄉", "長治鄉", "瑪家鄉", "崁頂鄉", "九如鄉", "來義鄉", "南州鄉", "鹽埔鄉", "獅子鄉", "琉球鄉", "萬巒鄉", "潮州鎮", "滿州鄉", "竹田鄉", "恆春鎮", "三地門鄉"],
    ["關山鎮", "金峰鄉", "成功鎮", "延平鄉", "臺東市", "海端鄉", "綠島鄉", "大武鄉", "太麻里鄉", "長濱鄉", "東河鄉", "池上鄉", "鹿野鄉", "蘭嶼鄉", "卑南鄉", "達仁鄉"],
    ["鳳林鎮", "卓溪鄉", "花蓮市", "萬榮鄉", "秀林鄉", "富里鄉", "瑞穗鄉", "豐濱鄉", "光復鄉", "壽豐鄉", "吉安鄉", "新城鄉", "玉里鎮"],
    ["馬公市", "七美鄉", "西嶼鄉", "望安鄉", "湖西鄉", "白沙鄉"],
    ["信義區", "中山區", "安樂區", "暖暖區", "仁愛區", "中正區", "七堵區"],
    ["東區", "香山區", "北區"],
    ["西區", "東區"],
    ["南港區", "文山區", "萬華區", "大同區", "中正區", "中山區", "大安區", "信義區", "松山區", "北投區", "士林區", "內湖區"],
    ["仁武區", "前金區", "梓官區", "岡山區", "前鎮區", "美濃區", "燕巢區", "小港區", "甲仙區", "鹽埕區", "阿蓮區", "林園區", "內門區", "左營區", "湖內區", "大樹區", "桃源區", "三民區", "永安區", "新興區", "彌陀區", "鳥松區", "苓雅區", "橋頭區", "旗津區", "六龜區", "田寮區", "鳳山區", "杉林區", "鼓山區", "路竹區", "大寮區", "茂林區", "楠梓區", "茄萣區", "大社區", "那瑪夏區", "旗山區"],
    ["瑞芳區", "三重區", "平溪區", "淡水區", "石門區", "泰山區", "新店區", "萬里區", "蘆洲區", "永和區", "貢寮區", "深坑區", "鶯歌區", "坪林區", "板橋區", "八里區", "土城區", "三芝區", "汐止區", "新莊區", "金山區", "林口區", "中和區", "雙溪區", "五股區", "三峽區", "樹林區", "烏來區", "石碇區"],
    ["外埔區", "新社區", "豐原區", "后里區", "北區", "太平區", "潭子區", "南屯區", "和平區", "大甲區", "中區", "烏日區", "沙鹿區", "南區", "龍井區", "石岡區", "東勢區", "北屯區", "西區", "霧峰區", "神岡區", "西屯區", "大里區", "大雅區", "大安區", "清水區", "東區", "大肚區", "梧棲區"],
    ["官田區", "東區", "山上區", "龍崎區", "新市區", "新化區", "下營區", "將軍區", "東山區", "歸仁區", "西港區", "安平區", "柳營區", "左鎮區", "佳里區", "北區", "鹽水區", "楠西區", "安定區", "大內區", "南區", "永康區", "麻豆區", "關廟區", "善化區", "後壁區", "仁德區", "北門區", "白河區", "南化區", "七股區", "中西區", "新營區", "玉井區", "學甲區", "安南區", "六甲區"],
    ["南竿鄉", "莒光鄉", "北竿鄉", "東引鄉"],
    ["金城鎮", "金沙鎮", "金湖鎮", "金寧鄉", "烈嶼鄉", "烏坵鄉"]]
    private init() {}
}

class AllCountyDomain {
    static let shared = AllCountyDomain()
    var allCityDomain = [County(chineseName: "宜蘭縣", englishName: "Yilan County", dayDomain: "F-D0047-001", weekDomain: "F-D0047-003"),
                         County(chineseName: "桃園市", englishName: "Taoyuan City", dayDomain: "F-D0047-005", weekDomain: "F-D0047-007"),
                         County(chineseName: "新竹縣", englishName: "Hsinchu County", dayDomain: "F-D0047-009", weekDomain: "F-D0047-011"),
                         County(chineseName: "苗栗縣", englishName: "Miaoli County", dayDomain: "F-D0047-013", weekDomain: "F-D0047-015"),
                         County(chineseName: "彰化縣", englishName: "Changhua County", dayDomain: "F-D0047-017", weekDomain: "F-D0047-019"),
                         County(chineseName: "南投縣", englishName: "Nantou County", dayDomain: "F-D0047-021", weekDomain: "F-D0047-023"),
                         County(chineseName: "雲林縣", englishName: "Yunlin County", dayDomain: "F-D0047-025", weekDomain: "F-D0047-027"),
                         County(chineseName: "嘉義縣", englishName: "Chiayi County", dayDomain: "F-D0047-029", weekDomain: "F-D0047-031"),
                         County(chineseName: "屏東縣", englishName: "Pingtung County", dayDomain: "F-D0047-033", weekDomain: "F-D0047-035"),
                         County(chineseName: "台東縣", englishName: "Taitung County", dayDomain: "F-D0047-037", weekDomain: "F-D0047-039"),
                         County(chineseName: "花蓮縣", englishName: "Hualien County", dayDomain: "F-D0047-041", weekDomain: "F-D0047-043"),
                         County(chineseName: "澎湖縣", englishName: "Penghu County", dayDomain: "F-D0047-045", weekDomain: "F-D0047-047"),
                         County(chineseName: "基隆市", englishName: "Keelung City", dayDomain: "F-D0047-049", weekDomain: "F-D0047-051"),
                         County(chineseName: "新竹市", englishName: "Hsinchu City", dayDomain: "F-D0047-053", weekDomain: "F-D0047-055"),
                         County(chineseName: "嘉義市", englishName: "Chiayi City", dayDomain: "F-D0047-057", weekDomain: "F-D0047-059"),
                         County(chineseName: "臺北市", englishName: "Taipei City", dayDomain: "F-D0047-061", weekDomain: "F-D0047-063"),
                         County(chineseName: "高雄市", englishName: "Kaohsiung City", dayDomain: "F-D0047-065", weekDomain: "F-D0047-067"),
                         County(chineseName: "新北市", englishName: "New Taipei City", dayDomain: "F-D0047-069", weekDomain: "F-D0047-071"),
                         County(chineseName: "臺中市", englishName: "Taichung City", dayDomain: "F-D0047-073", weekDomain: "F-D0047-075"),
                         County(chineseName: "臺南市", englishName: "Tainan City", dayDomain: "F-D0047-077", weekDomain: "F-D0047-079"),
                         County(chineseName: "連江縣", englishName: "Lienchiang County", dayDomain: "F-D0047-081", weekDomain: "F-D0047-083"),
                         County(chineseName: "金門縣", englishName: "Kinmen County", dayDomain: "F-D0047-085", weekDomain: "F-D0047-087")
                         ]
    private init() {}
}
