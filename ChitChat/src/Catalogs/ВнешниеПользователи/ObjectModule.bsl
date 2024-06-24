///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

// Значения объекта до записи для использования в обработчике события ПриЗаписи.
Перем ЭтоНовый, СтарыйОбъектАвторизации;
Перем ПараметрыОбработкиПользователяИБ; // Параметры, заполняемые при обработке пользователя ИБ.

#КонецОбласти

// *Область ПрограммныйИнтерфейс.
//
// Программный интерфейс объекта реализован через ДополнительныеСвойства:
//
// ОписаниеПользователяИБ - Структура, как и в модуле объекта справочника Пользователи.
//
// *КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	// АПК:75-выкл проверка ОбменДанными.Загрузка должна быть после обработки пользователя ИБ, когда требуется.
	ПользователиСлужебный.ПользовательОбъектПередЗаписью(ЭтотОбъект, ПараметрыОбработкиПользователяИБ);
	// АПК:75-вкл
	
	// АПК:75-выкл проверка ОбменДанными.Загрузка должна быть после блокировки регистра.
	Если ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		// Установка сразу исключительной блокировки на регистры вместо установки
		// разделяемой блокировки автоматически при чтении, которая приводит
		// к взаимоблокировке при обновлении составов групп пользователей.
		Блокировка = Новый БлокировкаДанных;
		Блокировка.Добавить("РегистрСведений.ИерархияГруппПользователей");
		Блокировка.Добавить("РегистрСведений.СоставыГруппПользователей");
		Блокировка.Добавить("РегистрСведений.СведенияОПользователях");
		Блокировка.Заблокировать();
	КонецЕсли;
	// АПК:75-вкл
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ЭтоНовый = ЭтоНовый();
	
	Если Не ЗначениеЗаполнено(ОбъектАвторизации) Тогда
		ТекстОшибки = НСтр("ru = 'У внешнего пользователя не задан объект авторизации.'");
		ВызватьИсключение ТекстОшибки;
	Иначе
		ТекстОшибки = "";
		Если ПользователиСлужебный.ОбъектАвторизацииИспользуется(
		         ОбъектАвторизации, Ссылка, , , ТекстОшибки) Тогда
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	КонецЕсли;
	
	// Проверка, что объект авторизации не изменен.
	Если ЭтоНовый Тогда
		СтарыйОбъектАвторизации = Null;
	Иначе
		СтарыйОбъектАвторизации = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
			Ссылка, "ОбъектАвторизации");
		
		Если ЗначениеЗаполнено(СтарыйОбъектАвторизации)
		   И СтарыйОбъектАвторизации <> ОбъектАвторизации Тогда
			
			ТекстОшибки = НСтр("ru = 'Невозможно изменить ранее указанный объект авторизации.'");
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	// АПК:75-выкл проверка ОбменДанными.Загрузка должна быть после обработки пользователя ИБ, когда требуется.
	Если ОбменДанными.Загрузка И ПараметрыОбработкиПользователяИБ <> Неопределено Тогда
		ПользователиСлужебный.ЗавершитьОбработкуПользователяИБ(
			ЭтотОбъект, ПараметрыОбработкиПользователяИБ);
	КонецЕсли;
	// АПК:75-вкл
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Обновление состава группы нового внешнего пользователя (если задана).
	Если ДополнительныеСвойства.Свойство("ГруппаНовогоВнешнегоПользователя")
	   И ЗначениеЗаполнено(ДополнительныеСвойства.ГруппаНовогоВнешнегоПользователя) Тогда
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.ГруппыВнешнихПользователей");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", ДополнительныеСвойства.ГруппаНовогоВнешнегоПользователя);
		Блокировка.Заблокировать();
		
		ОбъектГруппы = ДополнительныеСвойства.ГруппаНовогоВнешнегоПользователя.ПолучитьОбъект(); // СправочникОбъект.ГруппыВнешнихПользователей
		ОбъектГруппы.Состав.Добавить().ВнешнийПользователь = Ссылка;
		ОбъектГруппы.Записать();
	КонецЕсли;
	
	// Обновление состава автоматической группы "Все внешние пользователи" и
	// групп с признаком ВсеОбъектыАвторизации.
	ИзмененияСоставов = ПользователиСлужебный.НовыеИзмененияСоставовГрупп();
	ПользователиСлужебный.ОбновитьИспользуемостьСоставовГруппПользователей(Ссылка, ИзмененияСоставов);
	ПользователиСлужебный.ОбновитьСоставГруппыВсеПользователи(Ссылка, ИзмененияСоставов);
	ПользователиСлужебный.ОбновитьСоставыГруппПоТипамОбъектовАвторизации(Неопределено,
		Ссылка, ИзмененияСоставов);
	
	ПользователиСлужебный.ЗавершитьОбработкуПользователяИБ(ЭтотОбъект,
		ПараметрыОбработкиПользователяИБ);
	
	ПользователиСлужебный.ПослеОбновленияСоставовГруппПользователей(ИзмененияСоставов);
	
	Если СтарыйОбъектАвторизации <> ОбъектАвторизации
	   И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		
		ОбъектыАвторизации = Новый Массив;
		Если СтарыйОбъектАвторизации <> Null Тогда
			ОбъектыАвторизации.Добавить(СтарыйОбъектАвторизации);
		КонецЕсли;
		ОбъектыАвторизации.Добавить(ОбъектАвторизации);
		МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
		МодульУправлениеДоступомСлужебный.ПослеИзмененияОбъектаАвторизацииВнешнегоПользователя(ОбъектыАвторизации);
	КонецЕсли;
	
	ИнтеграцияПодсистемБСП.ПослеДобавленияИзмененияПользователяИлиГруппы(Ссылка, ЭтоНовый);
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	// АПК:75-выкл проверка ОбменДанными.Загрузка должна быть после обработки пользователя ИБ, когда требуется.
	ПользователиСлужебный.ПользовательОбъектПередУдалением(ЭтотОбъект);
	// АПК:75-вкл
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ПользователиСлужебный.ОбновитьСоставыГруппПередУдалениемПользователяИлиГруппы(Ссылка);
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	ДополнительныеСвойства.Вставить("ЗначениеКопирования", ОбъектКопирования.Ссылка);
	
	ИдентификаторПользователяИБ = Неопределено;
	ИдентификаторПользователяСервиса = Неопределено;
	Подготовлен = Ложь;
	
	Комментарий = "";
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли