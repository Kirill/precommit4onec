// BSLLS:LineLength-off

///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль, реализующий функционал проверки нахождения на поставке
//	обрабатываемых модулей.
//
///////////////////////////////////////////////////////////////////////////////

Перем КонфигурацияНаПоддержке;
Перем КонфигурацияВФорматеEDT;
Перем НастройкиПоддержки;
Перем ПроверенныеОбъекты;

#Область ПрограммныйИнтерфейс

// Проверяет существование файла поставки ParentConfigurations.bin в каталоге репозитория. Поддерживает
//	репозитории в формате EDT и выгрузку в файлы .xml средствами Конфигуратора.
//
// Параметры:
//	АнализируемыйФайл - Файл - Файл анализируемого модуля программного кода *.bsl.
//	ДополнительныеПараметры - <Структура> - <Должна содержать ключи:
//							- КаталогРепозитория - Строка - Адрес каталога проекта конфигурации,
//							- Настройки - НастройкиРепозитория - инициализированный объект настроек репозитория.>
//
// Возвращаемое значение:
//   <Булево> - флаг наличия файла поставки в каталоге репозитория.
//
Функция КонфигурацияНаПоддержке(АнализируемыйФайл, ДополнительныеПараметры) Экспорт
	Проект = МенеджерНастроек.ИмяПроектаДляФайла(АнализируемыйФайл.ПолноеИмя);
	ДополнительныеПараметры.Вставить("Проект", Проект);
	
	НаПоддержке = ЗначениеНастройкиДляПроекта(КонфигурацияНаПоддержке, Проект);
	Если НаПоддержке <> Неопределено Тогда
		Возврат НаПоддержке;
	КонецЕсли;

	КаталогПроекта = ФайловыеОперации.НормализоватьРазделители(ОбъединитьПути(ДополнительныеПараметры.КаталогРепозитория, Проект));
	Файлы = НайтиФайлы(КаталогПроекта, "ParentConfigurations.bin", Истина);
	Если Файлы.Количество() = 0 Тогда
		ДополнительныеПараметры.Лог.Информация("Файл ParentConfigurations.bin не найден в каталоге: '%1'", КаталогПроекта);
		УстановитьНастройкуДляПроекта(КонфигурацияНаПоддержке, Проект, Ложь);
		УстановитьНастройкуДляПроекта(КонфигурацияВФорматеEDT, Проект, Ложь);
		Возврат Ложь;
	КонецЕсли;

	Файл = Файлы[0];
	НаПоддержке = Истина;
	ФорматEDT = НайтиВхождения(Файл.ПолноеИмя, "Configuration[\\/]ParentConfigurations.bin") <> Неопределено;
	ПрочитатьДанныеФайлаПоддержки(Файл.ПолноеИмя, Проект);
	
	УстановитьНастройкуДляПроекта(КонфигурацияНаПоддержке, Проект, НаПоддержке);
	УстановитьНастройкуДляПроекта(КонфигурацияВФорматеEDT, Проект, ФорматEDT);
	Возврат НаПоддержке;
КонецФункции

// Проверяет наличие записи о владельце модуля в файле поставки ParentConfigurations.bin. В зависимости от формата репозитория,
//	поиск идентификатора владельца осуществляется в файлах *.mdo и *.xml.
//
// Параметры:
//   АнализируемыйФайл - Файл - Файл анализируемого модуля программного кода *.bsl.
//   ДополнительныеПараметры - Структура - <Должна содержать ключи:
//							- КаталогРепозитория - Строка - Адрес каталога проекта конфигурации,
//							- Настройки - НастройкиРепозитория - инициализированный объект настроек репозитория.>
//
//  Возвращаемое значение:
//   Булево - флаг наличия записи о владельце проверяемого модуля в файле поставки.
//
Функция ЭтоМодульОбъектаПоставки(АнализируемыйФайл, ДополнительныеПараметры) Экспорт
	Если НЕ КонфигурацияНаПоддержке(АнализируемыйФайл, ДополнительныеПараметры) ИЛИ НЕ ЭтоМодульОбъекта(АнализируемыйФайл) Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ЭтоМодульКонфигурации(АнализируемыйФайл) Тогда
		Возврат Истина;
	КонецЕсли;

	ВладелецМодуля = ИмяВладельцаМодуля(АнализируемыйФайл, ДополнительныеПараметры);
	Если ПустаяСтрока(ВладелецМодуля) Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ПроверенныеОбъекты <> Неопределено Тогда
		КэшированноеЗначение = ПроверенныеОбъекты.Получить(ВладелецМодуля);
		Если КэшированноеЗначение <> Неопределено Тогда
			Возврат КэшированноеЗначение;
		КонецЕсли;
	Иначе
		ПроверенныеОбъекты = Новый Соответствие;
	КонецЕсли;

	Идентификатор = ИдентификаторОбъекта(ВладелецМодуля);
	Если ПустаяСтрока(Идентификатор) Тогда
		Возврат Ложь;
	КонецЕсли;

	Значение = ЗначениеНастройкиДляПроекта(НастройкиПоддержки, ДополнительныеПараметры.Проект);
	НаПоддержке = СтрНайти(Значение, Идентификатор) > 0;
	ПроверенныеОбъекты.Вставить(ВладелецМодуля, НаПоддержке);

	Возврат НаПоддержке;
КонецФункции

#КонецОбласти

#Область Служебные

Функция ЗначениеНастройкиДляПроекта(Настройка, Проект)
	Если Настройка = Неопределено Тогда
		Настройка = Новый Соответствие;
	КонецЕсли;

	Возврат Настройка.Получить(Проект);
КонецФункции

Процедура УстановитьНастройкуДляПроекта(Настройка, Проект, Значение)
	Если Настройка = Неопределено Тогда
		Настройка = Новый Соответствие;
	КонецЕсли;

	Настройка.Вставить(Проект, Значение);
КонецПроцедуры

Процедура ПрочитатьДанныеФайлаПоддержки(ИмяФайла, Проект)
	ДанныеОбъекта = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	УстановитьНастройкуДляПроекта(НастройкиПоддержки, Проект, ДанныеОбъекта);
КонецПроцедуры

Функция ИдентификаторОбъекта(ИмяФайла)
	Файл = Новый Файл(ИмяФайла);
	Если НЕ Файл.Существует() Тогда
		Возврат "";
	КонецЕсли;
	
	ДанныеОбъекта = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	
	Вхождения = НайтиВхождения(ДанныеОбъекта, "<.+ uuid=""(\S{36})"">");
	Возврат ?(Вхождения = Неопределено, "", Вхождения[1]);
КонецФункции

Функция ИмяВладельцаМодуля(АнализируемыйФайл, ДополнительныеПараметры)
	Результат = "";

	СоответствиеМодулейИОбъектов = СоответствиеМодулейИОбъектов(ДополнительныеПараметры.Проект);
	ПараметрыПоиска = СоответствиеМодулейИОбъектов.Получить(АнализируемыйФайл.Имя);
	Если ПараметрыПоиска = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;

	ОтносительныйПуть = ОтносительныйПуть(АнализируемыйФайл.ПолноеИмя, ДополнительныеПараметры.КаталогРепозитория);
	Вхождения = НайтиВхождения(ОтносительныйПуть, ПараметрыПоиска.Выражение);
	Если Вхождения = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;

	КаталогКонфигурации = СтрЗаменить(АнализируемыйФайл.ПолноеИмя, Вхождения[0], "");
	Результат = ОбъединитьПути(КаталогКонфигурации, СтрШаблон(ПараметрыПоиска.ШаблонПути, Вхождения[1], Вхождения[2]));
	
	Возврат Результат;
КонецФункции

Функция СоответствиеМодулейИОбъектов(Проект)
	ФорматEDT = ЗначениеНастройкиДляПроекта(КонфигурацияВФорматеEDT, Проект);
	Если ФорматEDT = Истина Тогда
		ПутьКОбъекту = "%1/%2/%2.mdo";
		Соответствие = Новый Соответствие;
		
		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "CommandModule.bsl",
			"(\w+)[\\/](\w+)[\\/](?:Commands[\\/]\w+[\\/])?CommandModule\.bsl");
		
		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "ManagerModule.bsl",
			"(\w+)[\\/](\w+)[\\/]ManagerModule.bsl");
		
		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "ValueManagerModule.bsl",
			"(\w+)[\\/](\w+)[\\/]ValueManagerModule.bsl");
	
		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "ObjectModule.bsl",
			"(\w+)[\\/](\w+)[\\/]ObjectModule\.bsl");

		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "RecordSetModule.bsl",
			"(\w+)[\\/](\w+)[\\/]RecordSetModule\.bsl");

		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "Module.bsl",
			"(\w+)[\\/](\w+)[\\/](?:Forms[\\/]\w+[\\/])?Module.bsl");
		
		Возврат Соответствие;
	Иначе
		ПутьКОбъекту = "%1/%2.xml";
		Соответствие = Новый Соответствие;

		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "CommandModule.bsl",
			"(\w+)[\\/](\w+)[\\/](?:Commands[\\/]\w+[\\/])?Ext[\\/]CommandModule\.bsl");
		
		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "ManagerModule.bsl",
			"(\w+)[\\/](\w+)[\\/]Ext[\\/]ManagerModule\.bsl");
		
		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "ValueManagerModule.bsl",
			"(\w+)[\\/](\w+)[\\/]Ext[\\/]ValueManagerModule\.bsl");
	
		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "ObjectModule.bsl",
			"(\w+)[\\/](\w+)[\\/]Ext[\\/]ObjectModule\.bsl");

		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "RecordSetModule.bsl",
			"(\w+)[\\/](\w+)[\\/]Ext[\\/]RecordSetModule\.bsl");

		ДобавитьПараметрыПоискаВКоллекцию(Соответствие, ПутьКОбъекту, "Module.bsl",
			"(\w+)[\\/](\w+)[\\/](?:Forms[\\/]\w+[\\/])?Ext[\\/](?:Form[\\/])?Module.bsl");

		Возврат Соответствие;
	КонецЕсли;
КонецФункции

Процедура ДобавитьПараметрыПоискаВКоллекцию(Коллекция, ШаблонПути, ИмяФайла, Выражение)
	ПараметрыПоиска = Новый Структура("ШаблонПути, Выражение", ШаблонПути, Выражение);
	Коллекция.Вставить(ИмяФайла, ПараметрыПоиска);
КонецПроцедуры

Функция ЭтоМодульОбъекта(Файл)
	МассивИменМодулей = Новый Массив();
	МассивИменМодулей.Добавить("OrdinaryApplicationModule.bsl");
	МассивИменМодулей.Добавить("ManagedApplicationModule.bsl");
	МассивИменМодулей.Добавить("SessionModule.bsl");
	МассивИменМодулей.Добавить("CommandModule.bsl");
	МассивИменМодулей.Добавить("ObjectModule.bsl");
	МассивИменМодулей.Добавить("ManagerModule.bsl");
	МассивИменМодулей.Добавить("Module.bsl");
	МассивИменМодулей.Добавить("ValueManagerModule.bsl");
	МассивИменМодулей.Добавить("RecordSetModule.bsl");

	ПозицияВМассиве = МассивИменМодулей.Найти(Файл.Имя);
	Возврат ПозицияВМассиве <> Неопределено;
КонецФункции

Функция ЭтоМодульКонфигурации(Файл)
	МассивИменМодулей = Новый Массив();
	МассивИменМодулей.Добавить("OrdinaryApplicationModule.bsl");
	МассивИменМодулей.Добавить("ManagedApplicationModule.bsl");
	МассивИменМодулей.Добавить("SessionModule.bsl");

	ПозицияВМассиве = МассивИменМодулей.Найти(Файл.Имя);
	Возврат ПозицияВМассиве <> Неопределено;
КонецФункции

Функция ОтносительныйПуть(ИмяФайла, Каталог)
	Разделитель = ПолучитьРазделительПути();
	
	Результат = ИмяФайла;
	Если Не ЗначениеЗаполнено(Каталог) Тогда
		Возврат Результат;
	КонецЕсли;

	СтрокаПоиска = ?(СтрЗаканчиваетсяНа(Каталог, Разделитель), Каталог, Каталог + Разделитель);
	Если СтрНачинаетсяС(ИмяФайла, СтрокаПоиска) Тогда
		Результат = СтрЗаменить(ИмяФайла, СтрокаПоиска, "");
		Возврат Результат;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Функция НайтиВхождения(Текст, Выражение)
	РегулярноеВыражение = Новый РегулярноеВыражение(Выражение);
	КоллекцияСовпадений = РегулярноеВыражение.НайтиСовпадения(Текст);
	Если КоллекцияСовпадений.Количество() > 0 Тогда
		Совпадение = КоллекцияСовпадений[0];
		Если Совпадение.Группы.Количество() = 0 Тогда
			ВызватьИсключение "Неверный шаблон регулярного выражения.";
		КонецЕсли;

		Результат = Новый Массив;
		Для каждого Группа Из Совпадение.Группы Цикл
			Результат.Добавить(Группа.Значение);
		КонецЦикла;

		Возврат Результат;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

#КонецОбласти
