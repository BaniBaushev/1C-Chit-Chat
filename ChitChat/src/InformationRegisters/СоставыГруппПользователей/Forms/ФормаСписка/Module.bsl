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
	
	ТолькоПросмотр = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВключитьВозможностьРедактирования(Команда)
	
	ТолькоПросмотр = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеРегистра(Команда)
	
	ПоказатьПредупреждение(, РезультатОбновленияДанных());
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция РезультатОбновленияДанных()
	
	ШаблонОбновлено = НСтр("ru = '%1: Обновление выполнено успешно.'");
	ШаблонОбновлениеНеТребуется = НСтр("ru = '%1: Обновление не требуется.'");
	
	ЕстьИзмененияИерархии = Ложь;
	ЕстьИзмененияСоставов = Ложь;
	
	РегистрыСведений.СоставыГруппПользователей.ОбновитьИерархиюИСоставы(ЕстьИзмененияИерархии,
		ЕстьИзмененияСоставов);
	
	Результат = Новый Массив;
	Результат.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		?(ЕстьИзмененияИерархии, ШаблонОбновлено, ШаблонОбновлениеНеТребуется),
		Метаданные.РегистрыСведений.ИерархияГруппПользователей.Представление()));
	
	Результат.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		?(ЕстьИзмененияСоставов, ШаблонОбновлено, ШаблонОбновлениеНеТребуется),
		Метаданные.РегистрыСведений.СоставыГруппПользователей.Представление()));
	
	Элементы.Список.Обновить();
	
	Возврат СтрСоединить(Результат, Символы.ПС);
	
КонецФункции

#КонецОбласти
