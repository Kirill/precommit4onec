Функция ПолучитьДочерниеЭлементыОписанияКонфигурации(Знач СодержимоеФайла, ЭтоEDT) Экспорт
	
	Элементы = Новый Структура("Количество,ДочерниеЭлементыСтрока,Совпадения", 0, "", Неопределено);
	
	Если ЭтоEDT Тогда
		Регексп = Новый РегулярноеВыражение("(<\/languages>\s+)^(?!.*languages)([\w\W]*)(<\/mdclass\:Configuration>)");

	Иначе
		Регексп = Новый РегулярноеВыражение("(<ChildObjects>\s+?)([\w\W]+?)(\s+<\/ChildObjects>)");
	КонецЕсли;
	
	Регексп.ИгнорироватьРегистр = Истина;
	Регексп.Многострочный = Истина;
	
	ДочерниеЭлементы = Регексп.НайтиСовпадения(СодержимоеФайла);
	Элементы.Количество = ДочерниеЭлементы.Количество();
	Элементы.Совпадения = ДочерниеЭлементы;
	
	Если НЕ Элементы.Количество = 0 Тогда // Если количество 0 вернется пустая коллекция
		
		Элементы.ДочерниеЭлементыСтрока = ДочерниеЭлементы[0].Группы[2].Значение;

		Если ЭтоEDT Тогда
			РегекспМетаданные = Новый РегулярноеВыражение("^\s+<[\w]+>([a-zA-Z]+)\.([а-яa-zA-ZА-Я0-9_]+)<\/[\w]+>");

		Иначе
			РегекспМетаданные = Новый РегулярноеВыражение("^\s+<([\w]+)>([а-яa-zA-ZА-Я0-9_]+)<\/[\w]+>");
		КонецЕсли;

		РегекспМетаданные.ИгнорироватьРегистр = Истина;
		РегекспМетаданные.Многострочный = Истина;
		Элементы.Совпадения = РегекспМетаданные.НайтиСовпадения(Элементы.ДочерниеЭлементыСтрока);
		
	КонецЕсли;
	
	Возврат Элементы;

КонецФункции

// Создать
//	Создает объект встроенного языка и возвращает его
// Параметры:
//   ТекстВыражения			- Строка - Текст выражения
//   ИгнорироватьРегистр	- Булево - Если включено, регистр символов не важен для поиска
//   Многострочный			- Булево - Если включено, ^ и $ соответствуют началу и концу строки
//
//  Возвращаемое значение:
//   РегулярноеВыражение - Объект
//
Функция Создать(ТекстВыражения,  ИгнорироватьРегистр = Истина, Многострочный = Истина) Экспорт

	Выражение = Новый РегулярноеВыражение(ТекстВыражения);
	Выражение.ИгнорироватьРегистр = Истина;
	Выражение.Многострочный = Истина;

	Возврат Выражение;
 
КонецФункции