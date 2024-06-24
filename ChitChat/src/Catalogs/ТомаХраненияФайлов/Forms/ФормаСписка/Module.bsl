///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.ПеренестиВсеФайлыВТома.Видимость = ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаСФайлами");
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.СписокКомментарий.Видимость = Ложь;
		Элементы.СписокМаксимальныйРазмер.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьСнятьПометкуУдаления(Команда)
	
	Если Элементы.Список.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	НачатьИзменениеПометкиУдаления(Элементы.Список.ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиФайлы(Команда)
	
	РаботаСФайламиСлужебныйКлиент.ПеренестиФайлы();
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьЦелостность(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	Если НЕ СтандартныеПодсистемыКлиент.ЭтоЭлементДинамическогоСписка(ТекущиеДанные) Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыОтчета = Новый Структура();
	ПараметрыОтчета.Вставить("СформироватьПриОткрытии", Истина);
	ПараметрыОтчета.Вставить("Отбор", Новый Структура("Том", ТекущиеДанные.Ссылка));
	
	ОткрытьФорму("Отчет.ПроверкаЦелостностиТома.ФормаОбъекта", ПараметрыОтчета);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура НачатьИзменениеПометкиУдаления(ТекущиеДанные)
	
	Если ТекущиеДанные.ПометкаУдаления Тогда
		ТекстВопроса = НСтр("ru = 'Снять с ""%1"" пометку на удаление?'");
	Иначе
		ТекстВопроса = НСтр("ru = 'Пометить ""%1"" на удаление?'");
	КонецЕсли;
	
	ПоказатьВопрос(Новый ОписаниеОповещения("ПродолжитьИзменениеПометкиУдаления", ЭтотОбъект, ТекущиеДанные),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстВопроса, ТекущиеДанные.Наименование),
		РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьИзменениеПометкиУдаления(Ответ, ТекущиеДанные) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Том = Элементы.Список.ТекущиеДанные.Ссылка;
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Том", Элементы.Список.ТекущиеДанные.Ссылка);
	ДополнительныеПараметры.Вставить("ПометкаУдаления", Неопределено);
	ДополнительныеПараметры.Вставить("Запросы", Новый Массив());
	ДополнительныеПараметры.Вставить("ИдентификаторФормы", УникальныйИдентификатор);
	
	ПодготовкаКУстановкеСнятиюПометкиУдаления(Том, ДополнительныеПараметры);
	
	ОповещениеОПродолжении = Новый ОписаниеОповещения(
		"ПродолжитьУстановкуСнятиеПометкиУдаления", ЭтотОбъект, ДополнительныеПараметры);
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
		МодульРаботаВБезопасномРежимеКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаВБезопасномРежимеКлиент");
		МодульРаботаВБезопасномРежимеКлиент.ПрименитьЗапросыНаИспользованиеВнешнихРесурсов(
			ДополнительныеПараметры.Запросы, ЭтотОбъект, ОповещениеОПродолжении);
	Иначе
		ВыполнитьОбработкуОповещения(ОповещениеОПродолжении, КодВозвратаДиалога.ОК);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПодготовкаКУстановкеСнятиюПометкиУдаления(Том, ДополнительныеПараметры)
	
	ЗаблокироватьДанныеДляРедактирования(Том, , ДополнительныеПараметры.ИдентификаторФормы);
	
	СвойстваТома = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(
		Том, "ПометкаУдаления,ПолныйПутьWindows,ПолныйПутьLinux");
	
	ДополнительныеПараметры.ПометкаУдаления = СвойстваТома.ПометкаУдаления;
	
	Если ДополнительныеПараметры.ПометкаУдаления Тогда
		// Пометка удаления установлена, ее требуется снять.
		
		Запрос = Справочники.ТомаХраненияФайлов.ЗапросНаИспользованиеВнешнихРесурсовДляТома(
			Том, СвойстваТома.ПолныйПутьWindows, СвойстваТома.ПолныйПутьLinux);
	Иначе
		// Пометка удаления не установлена, ее требуется установить.
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
			МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
			Запрос = МодульРаботаВБезопасномРежиме.ЗапросНаОчисткуРазрешенийИспользованияВнешнихРесурсов(Том)
		КонецЕсли;
	КонецЕсли;
	
	ДополнительныеПараметры.Запросы.Добавить(Запрос);
	
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьУстановкуСнятиеПометкиУдаления(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.ОК Тогда
		ЗавершитьУстановкуСнятиеПометкиУдаления(ДополнительныеПараметры);
		Элементы.Список.Обновить();
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗавершитьУстановкуСнятиеПометкиУдаления(ДополнительныеПараметры)
	
	НачатьТранзакцию();
	Попытка
	
		БлокировкаДанных = Новый БлокировкаДанных;
		ЭлементБлокировкиДанных = БлокировкаДанных.Добавить(Метаданные.Справочники.ТомаХраненияФайлов.ПолноеИмя());
		ЭлементБлокировкиДанных.УстановитьЗначение("Ссылка", ДополнительныеПараметры.Том);
		БлокировкаДанных.Заблокировать();
		
		Объект = ДополнительныеПараметры.Том.ПолучитьОбъект();
		Объект.УстановитьПометкуУдаления(Не ДополнительныеПараметры.ПометкаУдаления);
		Объект.Записать();
		
		РазблокироватьДанныеДляРедактирования(
		ДополнительныеПараметры.Том, ДополнительныеПараметры.ИдентификаторФормы);
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти