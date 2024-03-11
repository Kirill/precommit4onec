﻿///////////////////////////////////////////////////////////////////
// Работает с настройками в конфигурационном файле репозитория 1С 
// в Git
//
// (с) BIA Technologies, LLC	
//
///////////////////////////////////////////////////////////////////

#Использовать json

///////////////////////////////////////////////////////////////////

Перем ИнициализацияВыполнена; // содержит признак инициализации репозитория
Перем НовыйКонфиг; // содержит признак нового конфига
Перем Конфигурация; // описание конфигурации
Перем АдресКонфигурационногоФайла; // адрес нахождения конфигурационного файла
Перем ОбновлятьКонфигурацию; // флаг необходимости обновления конфигурации / затирания

///////////////////////////////////////////////////////////////////
// Программный интерфейс
///////////////////////////////////////////////////////////////////

// ЭтоНовый
//	Возвращает признак нового конфига, т.е. отсутствие файла
//
// Возвращаемое значение:
//   Булево   - Признак отсутствия файла
//
Функция ЭтоНовый() Экспорт
	
	Возврат НовыйКонфиг;
	
КонецФункции // ЭтоНовый()

// НастройкиПриложения
//	Возвращает набор настроек для приложения
//
// Параметры:
//  ИмяПриложения  - Строка - Имя приложения
//
// Возвращаемое значение:
//   Соответствие - Набор настроек при их наличии, если настроек нет то будет возвращено пустое соответствие
//
Функция НастройкиПриложения(ИмяПриложения) Экспорт
	
	ПроверкаИнициализации();
	Если ПустаяСтрока(ИмяПриложения) Тогда
		
		ВызватьИсключение "Не указано имя приложения";
		
	КонецЕсли;

	ИскомыеНастройки = Конфигурация.Получить(ИмяПриложения);
	
	Если ИскомыеНастройки = Неопределено Тогда
		
		ИскомыеНастройки = Новый Соответствие;
		
	КонецЕсли;
	
	Возврат ИскомыеНастройки;
	
КонецФункции // НастройкиПриложения()

// Настройка
//	Возвращает значение искомой настройки
//
// Параметры:
//  ИмяНастройки  - Строка - Имя искомой настройки. Возможные форматы
//				- "МояНастройка" - для чтения глобальной настройки
//				- "МоеПриложение\МояНастройка" - для чтения настройки приложения
//
// Возвращаемое значение:
//   Произвольный   - Значение настройки
//
Функция Настройка(ИмяНастройки) Экспорт
	
	ПроверкаИнициализации();
	
	РазложенноеИмяНастройки = РазобратьИмяНастройки(ИмяНастройки);
	ИскомоеПриложение = НастройкиПриложения(РазложенноеИмяНастройки.ИмяПриложения);
	Возврат ИскомоеПриложение.Получить(РазложенноеИмяНастройки.ИмяНастройки);
	
КонецФункции // Настройка(ИмяНастройки)

// ЗаписатьНастройку
//	Записывает настройку в конфигурационный файл
//
// Параметры:
//  ИмяНастройки  - Строка - Имя искомой настройки. Возможные форматы
//				- "МояНастройка" - для чтения глобальной настройки
//				- "МоеПриложение\МояНастройка" - для чтения настройки приложения
//
//  Значение  - Произвольный - Значение настройки, сериализуемое в JSON
//
Процедура ЗаписатьНастройку(ИмяНастройки, Значение) Экспорт
	
	ПроверкаИнициализации();
	
	РазложенноеИмяНастройки = РазобратьИмяНастройки(ИмяНастройки);
	ИскомоеПриложение = НастройкиПриложения(РазложенноеИмяНастройки.ИмяПриложения);
	Если ОбновлятьКонфигурацию ИЛИ ИскомоеПриложение.Получить(РазложенноеИмяНастройки.ИмяНастройки) = Неопределено Тогда
		
		ИскомоеПриложение.Вставить(РазложенноеИмяНастройки.ИмяНастройки, Значение);
		
	КонецЕсли;
	Конфигурация.Вставить(РазложенноеИмяНастройки.ИмяПриложения, ИскомоеПриложение);
	
	ОбновитьКонфигурационныйФайл();
	
КонецПроцедуры // ЗаписатьНастройку(ИмяНастройки, Значение)

// ЗаписатьНастройкиПриложения
//	Записывает набор настроек приложения
//
// Параметры:
//  ИмяПриложения  	- Строка - Имя приложения
//  Значение  		- Соответствие - Набор настроек приложения
//
Процедура ЗаписатьНастройкиПриложения(ИмяПриложения, Значение) Экспорт
	
	ПроверкаИнициализации();
	
	Если ПустаяСтрока(ИмяПриложения) Тогда
		
		ВызватьИсключение "Не указано имя приложения";
		
	КонецЕсли;
	
	Если ТипЗнч(Значение) <> Тип("Соответствие") Тогда
		
		ВызватьИсключение "Тип значения должен быть Соответствие";
		
	КонецЕсли;
	
	Конфигурация.Вставить(ИмяПриложения, Значение);
	
	ОбновитьКонфигурационныйФайл();
	
КонецПроцедуры // ЗаписатьНастройкиПриложения()

// УдалитьНастройкиПриложения
//	Удаляет набор набор настроек приложения
//
// Параметры:
//  ИмяПриложения  	- Строка - Имя приложения
//
Процедура УдалитьНастройкиПриложения(ИмяПриложения) Экспорт
	
	ПроверкаИнициализации();

	Если ПустаяСтрока(ИмяПриложения) Тогда
		
		ВызватьИсключение "Не указано имя приложения";
		
	КонецЕсли;
	
	Конфигурация.Удалить(ИмяПриложения);
	
	ОбновитьКонфигурационныйФайл();
	
КонецПроцедуры // УдалитьНастройкиПриложения()

Процедура УдалитьНастройку(ИмяПриложения, ИмяНастройки) Экспорт
	
	ПроверкаИнициализации();

	Если ПустаяСтрока(ИмяПриложения) Тогда
		
		ВызватьИсключение "Не указано имя приложения";
		
	КонецЕсли;
	Временный = Конфигурация.Получить(ИмяПриложения);
	Временный.Удалить(ИмяНастройки);
	Конфигурация.Вставить(ИмяПриложения, Временный);
	ОбновитьКонфигурационныйФайл();
	
КонецПроцедуры // УдалитьНастройкиПриложения()

///////////////////////////////////////////////////////////////////
// Служебный функционал
///////////////////////////////////////////////////////////////////

Функция ПроверкаИнициализации()
	
	Если Не ИнициализацияВыполнена Тогда
		
		ВызватьИсключение "Необходимо выполнить инициализацию";
		
	КонецЕсли;

	Возврат Истина;
	
КонецФункции // ПроверкаИнициализации() 

Функция РазобратьИмяНастройки(Знач ИмяНастройки)
	
	Если ПустаяСтрока(ИмяНастройки) Тогда
		
		ВызватьИсключение "Не передано имя настройки";
		
	КонецЕсли;
	
	ПозицияРазделителя = СтрНайти(ИмяНастройки, "\", НаправлениеПоиска.СКонца);
	Если ПозицияРазделителя > 0 Тогда
		
		ИмяПриложения = Лев(ИмяНастройки, ПозицияРазделителя - 1);
		ИмяНастройки = Сред(ИмяНастройки, ПозицияРазделителя + 1);
		
	КонецЕсли;
	
	Возврат Новый Структура("ИмяПриложения, ИмяНастройки", ИмяПриложения, ИмяНастройки);
	
КонецФункции // РазобратьИмяНастройки()

Процедура ОбновитьКонфигурационныйФайл()
	
	ПарсерJSON = Новый ПарсерJSON;
	ТекстКонфигурации = ПарсерJSON.ЗаписатьJSON(Конфигурация);
	Запись = Новый ЗаписьТекста(АдресКонфигурационногоФайла, КодировкаТекста.UTF8NoBOM);
	Запись.Записать(ТекстКонфигурации);
	Запись.Закрыть();
	
	НовыйКонфиг = Ложь;

КонецПроцедуры // ОбновитьКонфигурационныйФайл()

///////////////////////////////////////////////////////////////////

// ПриСозданииОбъекта
//	Инициализирует объект при создании
//	
// Параметры:
//  КаталогРепозитория - Строка - Адрес каталога репозитория
//  ОбновлятьКонф - Булево - флаг необходимости обновления конфигурации / затирания
//
Процедура ПриСозданииОбъекта(КаталогРепозитория, ОбновлятьКонф = Ложь)
	
	ИнициализацияВыполнена = Ложь;
	НовыйКонфиг = Ложь;
	Конфигурация = Неопределено;
	АдресКонфигурационногоФайла = "";
	ОбновлятьКонфигурацию = ?(ОбновлятьКонф = Неопределено, Ложь, ОбновлятьКонф);
	Файл = Новый Файл(КаталогРепозитория);
	АдресКонфигурационногоФайла = "";
	Если НЕ Файл.Существует() Тогда

		ВызватьИсключение "Каталог репозитория или файл настроек '" + КаталогРепозитория + "' не обнаружен";
		
	ИначеЕсли Файл.ЭтоФайл() Тогда
		
		АдресКонфигурационногоФайла = Файл.ПолноеИмя;

	Иначе
		
		АдресКонфигурационногоФайла = ОбъединитьПути(КаталогРепозитория, "v8config.json");
		
	КонецЕсли;

	Файл = Новый Файл(АдресКонфигурационногоФайла);
	Если Файл.Существует() Тогда
		
		Чтение = Новый ЧтениеТекста(АдресКонфигурационногоФайла, КодировкаТекста.UTF8NoBOM);
		ТекстКонфигурации = Чтение.Прочитать();
		Чтение.Закрыть();
		
		ПарсерJSON = Новый ПарсерJSON;
		Конфигурация = ПарсерJSON.ПрочитатьJSON(ТекстКонфигурации);
		
	Иначе
		
		НовыйКонфиг = Истина;
		Конфигурация = Новый Соответствие;
		
	КонецЕсли;
	
	ИнициализацияВыполнена = Истина;
	
КонецПроцедуры // ПриСозданииОбъекта()

Процедура ОбновитьКонфигурацию() Экспорт
	ОбновлятьКонфигурацию = Истина;
КонецПроцедуры
