package  {
	
	import flash.display.MovieClip;
	import fl.events.SliderEvent;
	import flash.net.SharedObject;
	import flash.events.FocusEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import fl.data.DataProvider;
	import flash.text.TextFormat;
	
	public class Main extends MovieClip {
		public var XMLdat:XML = new XML();
		public var sharedDat:SharedObject = SharedObject.getLocal("user");
		var my_timedProcess:Number = setTimeout(delayedStartUp, 30);
		
		public function Main() {
			breakSlider.addEventListener(SliderEvent.THUMB_DRAG, calcSliders);
			lunSlider.addEventListener(SliderEvent.THUMB_DRAG, calcSliders);
			dinSlider.addEventListener(SliderEvent.THUMB_DRAG, calcSliders);
			addPurch_btn.addEventListener(MouseEvent.CLICK, addPurchase);
			setAmount_btn.addEventListener(MouseEvent.CLICK, setAmount);
			addAmount_btn.addEventListener(MouseEvent.CLICK, addAmount);
			purchasesDataGrid.addEventListener(Event.CHANGE, itemFocus);
			
			//sharedDat.clear();
			calcSliders(null);
			setUpPurchases();
		}
		
		private function initialSetUp():void{
			breakSlider.value = lunSlider.value = dinSlider.value = 50;
			XMLdat = <user>
						<purchases>
						</purchases>
					</user>
					
			mealPlanSelector.selectedIndex = 0;
			exclWeekend.selected = false;
			
			saveXML();
			calcSliders(null);
			
			//setUpPurchases();
			
		}		
		
		private function loadXML():void{
			trace("load");
			trace(XMLdat);
			//load slider values
			breakSlider.value = XMLdat.sliders.breakSlider;
			lunSlider.value = XMLdat.sliders.lunSlider;
			dinSlider.value = XMLdat.sliders.dinSlider;
			calcSliders(null);
			
			//load dates
			strDateyr_txt.text = XMLdat.dates.startDate.year;
			strDate_month.selectedIndex = XMLdat.dates.startDate.month;
			strDate_day.selectedIndex = XMLdat.dates.startDate.day;
			endDateyr_txt.text = XMLdat.dates.endDate.year;
			endDate_month.selectedIndex = XMLdat.dates.endDate.month;
			endDate_day.selectedIndex = XMLdat.dates.endDate.day;
			
			//load other stuff
			var values:Array = [3270,3420,3620,3820,4020,2425,2575,2775,2975,3175];
			
			for (var i:int=0;i<values.length;i++){
				if(values[i] == XMLdat.mealPlan){
					break;
				}
			}
			mealPlanSelector.selectedIndex = i;
			
			if(XMLdat.exclusions.exclWeekends == "true"){
				exclWeekend.selected = true;
			}else{
				exclWeekend.selected = false;
			}
			
			refreshPurchases();
		}
		
		private function saveXML():void{
			//save sliders
			XMLdat.sliders.breakSlider = breakSlider.value;
			XMLdat.sliders.lunSlider = lunSlider.value;
			XMLdat.sliders.dinSlider = dinSlider.value;
			
			//save dates
			XMLdat.dates.startDate.year = int(strDateyr_txt.text);
			XMLdat.dates.startDate.month = strDate_month.value;
			XMLdat.dates.startDate.day = int(strDate_day.value)-1;
			XMLdat.dates.endDate.year = int(endDateyr_txt.text);
			XMLdat.dates.endDate.month = endDate_month.value;
			XMLdat.dates.endDate.day = int(endDate_day.value)-1;
			
			//save other stuff
			XMLdat.mealPlan = mealPlanSelector.value;
			XMLdat.exclusions.exclWeekends = exclWeekend.selected;
			
			sharedDat.data.user = XMLdat;
		}
		
		public var breakPer:Number;
		public var lunPer:Number;
		public var dinPer:Number;
		private function calcSliders(e:SliderEvent):void{
			var breakVal:int=breakSlider.value;
			var lunVal:int=lunSlider.value;
			var dinVal:int=dinSlider.value;
			
			var totalVal:int = breakVal+lunVal+dinVal;
			
			breakPer = Math.round(breakVal/totalVal*100);
			lunPer = Math.round(lunVal/totalVal*100);
			dinPer = Math.round(dinVal/totalVal*100);
			
			if((breakPer+lunPer+dinPer)>100){
				if(e != null){
						if(e.currentTarget.name == "breakSlider"){
						breakPer-=(breakPer+lunPer+dinPer)%100;
					}else if(e.currentTarget.name == "lunSlider"){
						lunPer-=(breakPer+lunPer+dinPer)%100;
					}else if(e.currentTarget.name == "dinSlider"){
						dinPer-=(breakPer+lunPer+dinPer)%100;
					}
				}
			}else if((breakPer+lunPer+dinPer)<100 && breakPer != 33 && lunPer != 33 && dinPer != 33){
				if(e != null){
						if(e.currentTarget.name == "breakSlider"){
						breakPer+=100-(breakPer+lunPer+dinPer);
					}else if(e.currentTarget.name == "lunSlider"){
						lunPer+=100-(breakPer+lunPer+dinPer)%100;
					}else if(e.currentTarget.name == "dinSlider"){
						dinPer+=100-(breakPer+lunPer+dinPer)%100;
					}
				}
			}
			
			breakOutput_txt.text = breakPer + "%";
			lunOutput_txt.text = lunPer + "%";
			dinOutput_txt.text = dinPer + "%";
			
			if(e != null){
				saveXML();
			}
			
			budget();
		}
		
		public function delayedStartUp():void{
			XMLdat = sharedDat.data.user;
			setUpDates();
			if (sharedDat.size == 0){
				initialSetUp();
			}else{
				loadXML();
			}
			strDate_month.addEventListener(Event.CHANGE, function(e:Event):void{calculateDays(strDateyr_txt,strDate_month, strDate_day);saveXML();budget();});
			strDateyr_txt.addEventListener(Event.CHANGE, function(e:Event):void{calculateDays(strDateyr_txt,strDate_month, strDate_day);saveXML();budget();});
			strDate_day.addEventListener(Event.CHANGE, function(e:Event):void{saveXML();budget();});
			endDate_month.addEventListener(Event.CHANGE, function(e:Event):void{calculateDays(endDateyr_txt,endDate_month, endDate_day);saveXML();budget();});
			endDateyr_txt.addEventListener(Event.CHANGE, function(e:Event):void{calculateDays(endDateyr_txt,endDate_month, endDate_day);saveXML();budget();});
			endDate_day.addEventListener(Event.CHANGE, function(e:Event):void{saveXML();budget();});
			buyDate_month.addEventListener(Event.CHANGE, function(e:Event):void{calculateDays(buyDateyr_txt,buyDate_month, buyDate_day);budget();});
			buyDateyr_txt.addEventListener(Event.CHANGE, function(e:Event):void{calculateDays(buyDateyr_txt,buyDate_month, buyDate_day);budget();});
			mealPlanSelector.addEventListener(Event.CHANGE, function(e:Event):void{saveXML();refreshPurchases();budget();});
			exclWeekend.addEventListener(Event.CHANGE, function(e:Event):void{saveXML();refreshPurchases();budget();});
			budget();
		}
		
		public function setUpDates():void{
			var currentYear:Date = new Date();
			strDateyr_txt.text = String(currentYear.getFullYear());
			endDateyr_txt.text = String(currentYear.getFullYear()+1);
			buyDateyr_txt.text = String(currentYear.getFullYear());
			strDate_month.selectedIndex = 8;
			endDate_month.selectedIndex = 3;
			buyDate_month.selectedIndex = currentYear.getMonth();	
			
			calculateDays(strDateyr_txt,strDate_month,strDate_day);//
			calculateDays(endDateyr_txt,endDate_month,endDate_day);
			calculateDays(buyDateyr_txt,buyDate_month,buyDate_day);
			
			strDate_day.selectedIndex = 0;
			endDate_day.selectedIndex = 29;
			buyDate_day.selectedIndex = currentYear.date;
		}
		
		private function calculateDays(yearIn,monthIn,dayIn):void{
			var year:int;
			var month:int;
			var date:int;
			var days:int;
			var dayA:DataProvider = new DataProvider();
			
			year = int(yearIn.text);
			month = int(monthIn.value);
			date = int(dayIn.selectedIndex);
			days = getNumberOfDays(year,month);
			
			for(var d:int=1;d<=days;d++){
				dayA.addItem({label:String(d),data:d});
			}
			
			dayIn.dataProvider = dayA;
			if(date > getNumberOfDays(year,month)-1){
				trace("hello");
				dayIn.selectedIndex = getNumberOfDays(year,month)-1;
			}else{
				dayIn.selectedIndex = date;
			}
			
		}
		
		private function getNumberOfDays($year:int, $month:int):int{
			var month:Date = new Date($year, $month + 1, 0);
			return month.date;
		}
		
		private function setUpPurchases():void{
			purchasesDataGrid.columns = ["Date","Description","Amount","Running Total"];
		}
		
		public var purchases:XMLList = new XMLList();
		private function refreshPurchases():void{
			var purchXML = sharedDat.data.user;
			purchases = XMLList(purchXML.purchases.entry);
			
			purchasesDataGrid.dataProvider = new DataProvider;
			var totalAmount:Number = Number(XMLdat.mealPlan);
			for(var i:int=0;i<purchases.length();i++){
				trace(purchases.amount[i]);
				totalAmount -= purchases.amount[i];
				purchasesDataGrid.addItem({ID:purchases.id[i],Date:purchases.date[i],Description:purchases.description[i],Amount:"$"+Number(purchases.amount[i]).toFixed(2),"Running Total":"$"+totalAmount.toFixed(2)});
			}
			budget();
		}
		
		private function addPurchase(e:MouseEvent):void{
			var purchXML = sharedDat.data.user;
			purchases = XMLList(purchXML.purchases.entry);
			
			var month:int = buyDate_month.selectedIndex+1;
			var day:int = buyDate_day.selectedIndex+1;
			var year:int = int(buyDateyr_txt.text);
			var amount:Number = Number(purchAmountIn_txt.text);
			var desc:String = descIn_txt.text;
			
			var date:String = month+"/"+day+"/"+year;
			
			var XMLstring:String = "<entry><id>"+purchases.length()+1+"</id><date>"+date+"</date><description>"+desc+"</description><amount>"+amount+"</amount></entry>"
			
			XMLdat.purchases.appendChild = XML(XMLstring);
			refreshPurchases();
		}
		
		private function budget():void{
			var startAmount = Number(XMLdat.mealPlan);
			var amountLeft = Number(XMLdat.mealPlan);
			for(var i:int=0;i<purchases.length();i++){
				trace(purchases.amount[i]);
				amountLeft -= purchases.amount[i];
			}
			var today:Date = new Date();
			
			var startDate:Date = new Date(int(XMLdat.dates.startDate.year),int(XMLdat.dates.startDate.month),int(XMLdat.dates.startDate.day));
			var endDate:Date = new Date(int(XMLdat.dates.endDate.year),int(XMLdat.dates.endDate.month),int(XMLdat.dates.endDate.day));
			
			var totalDays:int = calculateDaysRange(startDate,endDate);
			var daysUsed:int = calculateDaysRange(startDate,today);
			var daysLeft:int = calculateDaysRange(today,endDate);
			
			var startingBudget:Number = startAmount / totalDays;
			var usedPerDay:Number = (startAmount-amountLeft)/daysUsed;
			var leftPerDay:Number = amountLeft/daysLeft;
			
			overviewOut_txt.text = "$"+startAmount.toFixed(2)+
									"\n$"+startAmount.toFixed(2)+
									"\n$"+startingBudget.toFixed(2)+
									"\n$"+(startAmount-amountLeft).toFixed(2)+
									"\n$"+amountLeft.toFixed(2)+
									"\n"+totalDays+
									"\n"+daysUsed+
									"\n"+daysLeft+
									"\n$"+usedPerDay.toFixed(2)+
									"\n$"+leftPerDay.toFixed(2);
			
			var TF:TextFormat = new TextFormat();
			if(leftPerDay > usedPerDay){
				aLine11_txt.text = "You are currently underbudget. You could afford to spend";
				aLine12_txt.text = "more/day than you are now.";
				aLine1O_txt.text = "$"+(leftPerDay-usedPerDay).toFixed(2);
				
				aLine21_txt.text = "Given the current rate of usage, you'll end up with"
				aLine22_txt.text = "leftover at the end of the year."
				aLine2O_txt.text = "$"+((leftPerDay-usedPerDay)*daysLeft).toFixed(2);
				
				TF.color = 0x00FF00;
				aLine1O_txt.setTextFormat(TF);
				aLine2O_txt.setTextFormat(TF);
			}else if (usedPerDay > leftPerDay){
				var moneyDaysLeft:Number = Math.round(amountLeft / usedPerDay);
				var date:Date = new Date();
				date.date += moneyDaysLeft;
				
				aLine11_txt.text = "You are currently overbudget. You are currently spending";
				aLine12_txt.text = "more/day than the budget.";
				aLine1O_txt.text = "$"+(usedPerDay-leftPerDay).toFixed(2);
				
				aLine21_txt.text = "Given the current rate of usage, you'll need to add"
				aLine22_txt.text = "on or around "+date.fullYear+"/"+(date.month+1)+"/"+date.date;
				aLine2O_txt.text = "$"+((usedPerDay-leftPerDay)*daysLeft).toFixed(2);
				
				TF.color = 0xFF0000;
				aLine1O_txt.setTextFormat(TF);
				aLine2O_txt.setTextFormat(TF);
			}
			
			perDayOut_txt.text = "$"+leftPerDay.toFixed(2);
			breakOut_txt.text = "$"+(leftPerDay*breakPer/100).toFixed(2);
			lunOut_txt.text = "$"+(leftPerDay*lunPer/100).toFixed(2);
			dinOut_txt.text = "$"+(leftPerDay*dinPer/100).toFixed(2);
		}
		
		private function calculateDaysRange(s:Date,e:Date):int{
			var aTms = Math.floor(e.valueOf() - s.valueOf());
			
			var days:int = aTms/1000/60/60/24;
			
			return days;
		}
		
		public function setAmount(e:MouseEvent):void{
			var startAmount = Number(XMLdat.mealPlan);
			var amountLeft = Number(XMLdat.mealPlan);
			for(var i:int=0;i<purchases.length();i++){
				trace(purchases.amount[i]);
				amountLeft -= purchases.amount[i];
			}
			var amount:Number = Number(setAddAmountIn_txt.text);
			var amountChange:Number = amountLeft-amount;
			
			
			var month:int = buyDate_month.selectedIndex+1;
			var day:int = buyDate_day.selectedIndex+1;
			var year:int = int(buyDateyr_txt.text);
			var amount:Number = Number(purchAmountIn_txt.text);
			var date:String = month+"/"+day+"/"+year;
			
			var XMLstring:String = "<entry><id>"+purchases.length()+1+"</id><date>"+date+"</date><description>Balance Correction</description><amount>"+amountChange+"</amount></entry>"
			XMLdat.purchases.appendChild = XML(XMLstring);
			refreshPurchases();
		}
		
		public function addAmount():void{
			//var XMLstring:String = "<entry><id>"+purchases.length()+1+"</id><date>"+date+"</date><description>"+desc+"</description><amount>"+amount+"</amount></entry>"
		}
		
		private function itemFocus(e:Event):void{
			remove_btn.visible = true;
			trace(e.target.selectedItem.ID);
		}
	}
}