

Функция Загрузить(УправлениеНастройками, КаталогРепозитория, Проект, ПараметрИменаЗагружаемыхСценариев = Неопределено) Экспорт
	
	ТекущийКаталогСценариев = МенеджерПриложения.КаталогСценариев();
	ВсеЗагруженные = Новый Массив;
	ФайлыГлобальныхСценариев = НайтиФайлы(ТекущийКаталогСценариев, "*.os");
	ФайлыЛокальныхСценариев = Новый Массив;


	Лог = МенеджерПриложения.ПолучитьЛог();
	
	Если ПараметрИменаЗагружаемыхСценариев <> Неопределено Тогда
		
		ИменаЗагружаемыхСценариев = ПараметрИменаЗагружаемыхСценариев;
		
	Иначе

		ИменаЗагружаемыхСценариев = МенеджерНастроек.ИменаЗагружаемыхСценариев(Проект);
		
	КонецЕсли;
	
		Если НЕ УправлениеНастройками.ЭтоНовый() Тогда
		
		Лог.Информация("Читаем настройки " + Проект);
		
		ИспользоватьСценарииРепозитория = МенеджерНастроек.ЗначениеНастройки("ИспользоватьСценарииРепозитория", Проект, Ложь);

		Если ИспользоватьСценарииРепозитория Тогда
			
			ЛокальныйКаталог = МенеджерНастроек.ЗначениеНастройки("КаталогЛокальныхСценариев", Проект);
			ПутьКЛокальнымСценариям = ОбъединитьПути(КаталогРепозитория, ЛокальныйКаталог);
			ФайлПутьКЛокальнымСценариям = Новый Файл(ПутьКЛокальнымСценариям);
			
			Если Не ФайлПутьКЛокальнымСценариям.Существует() ИЛИ ФайлПутьКЛокальнымСценариям.ЭтоФайл() Тогда
				
				Лог.Ошибка("Сценарии из репозитория не загружены т.к. отсутствует каталог %1", ЛокальныйКаталог);
				
			Иначе
				
				ФайлыЛокальныхСценариев = НайтиФайлы(ФайлПутьКЛокальнымСценариям.ПолноеИмя, "*.os");
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ЗагрузитьИзКаталога(ВсеЗагруженные, ФайлыГлобальныхСценариев, ИменаЗагружаемыхСценариев);
	ЗагрузитьИзКаталога(ВсеЗагруженные, ФайлыЛокальныхСценариев, , Истина);
	
	Если ВсеЗагруженные.Количество() = 0 Тогда
		
		ВызватьИсключение "Нет доступных сценариев обработки файлов";
		
	КонецЕсли;
	
	Возврат ВсеЗагруженные;
	
КонецФункции

Процедура ЗагрузитьИзКаталога(ВсеЗагруженные, ФайлыСценариев, 
										Знач ИменаЗагружаемыхСценариев = Неопределено, 
										ЗагрузитьВсе = Ложь) Экспорт
	Лог = МенеджерПриложения.ПолучитьЛог();
	
	Если ИменаЗагружаемыхСценариев = Неопределено Тогда
		
		ИменаЗагружаемыхСценариев = Новый Массив;
		
	КонецЕсли;
	
	Для Каждого ФайлСценария Из ФайлыСценариев Цикл		
		
		Если СтрСравнить(ФайлСценария.ИмяБезРасширения, "ШаблонСценария") = 0 Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Если НЕ ЗагрузитьВсе 
				И ИменаЗагружаемыхСценариев.Найти(ФайлСценария.Имя) = Неопределено
				И ИменаЗагружаемыхСценариев.Найти(ФайлСценария.ИмяБезРасширения) = Неопределено Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Попытка
			
			СценарийОбработки = ЗагрузитьСценарий(ФайлСценария.ПолноеИмя);
			ВсеЗагруженные.Добавить(СценарийОбработки);
			
		Исключение
			
			Лог.Ошибка("Ошибка загрузки сценария %1: %2", ФайлСценария.ПолноеИмя, ОписаниеОшибки());
			Продолжить;
			
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьСтандартныеПараметрыОбработки() Экспорт
	Лог = МенеджерПриложения.ПолучитьЛог();
	ПараметрыОбработки = Новый Структура();
	ПараметрыОбработки.Вставить("Лог", Лог);
	ПараметрыОбработки.Вставить("ФайлыДляПостОбработки", Новый Массив);
	ПараметрыОбработки.Вставить("ИзмененныеКаталоги", Новый Массив);
	ПараметрыОбработки.Вставить("КаталогРепозитория", Неопределено);
	ПараметрыОбработки.Вставить("Настройки", Неопределено);

	Возврат ПараметрыОбработки;
	
КонецФункции

// <Возвращает соответствие со сценариями и их настройками>
//
// Параметры:
//   КаталогРепозитория - <Строка> - <описание параметра>
//   УправлениеНастройками - <Тип.Вид> - <описание параметра>
//   ИменаЗагружаемыхСценариев - <Тип.Вид> - <описание параметра>
//
//  Возвращаемое значение:
//   <Соответствие> - <ключ - Ключ структуры настроек прокоммит или 
//							путь к каталогу, который обрабатывается 
//							нестандартными правилами > 
//
Функция ПолучитьСценарииСПараметрамиВыполнения(КаталогРепозитория, УправлениеНастройками, ИменаЗагружаемыхСценариев = Неопределено) Экспорт
	
	
	ПараметрыОбработки = СценарииОбработки.ПолучитьСтандартныеПараметрыОбработки();
	ПараметрыОбработки.КаталогРепозитория = КаталогРепозитория;
	НастройкиПроектов = УправлениеНастройками.ПолучитьПроектыКонфигурации();
	НаборНастроек = Новый Соответствие;
	
	Для Каждого ЭлементНастройки Из НастройкиПроектов Цикл
		Настройка = Новый Структура("СценарииОбработки, НастройкиСценариев");
		
		Настройка.СценарииОбработки = СценарииОбработки.Загрузить(УправлениеНастройками,
				КаталогРепозитория,
				ЭлементНастройки,
				ИменаЗагружаемыхСценариев);
		ПараметрыОбработки.Настройки = УправлениеНастройками.НастройкиПриложения(ЭлементНастройки).Получить("НастройкиСценариев");
		Настройка.НастройкиСценариев = ПараметрыОбработки;
		
		НаборНастроек.Вставить(ЭлементНастройки, Настройка);
	КонецЦикла;

	Возврат НаборНастроек;
КонецФункции


Функция ПолучитьПараметрыОбработкиФайла(ИмяФайла, НастройкиПроектов) Экспорт
	
	ИмяОбщейНастройки = МенеджерНастроек.КлючНастройкиPrecommit();
	НайденнаяНастройка = НастройкиПроектов.Получить(ИмяОбщейНастройки);
	
	Для Каждого ЭлементНастройки Из НастройкиПроектов Цикл
		
		Если ЭлементНастройки.Ключ = ИмяОбщейНастройки Тогда
			
			Продолжить;
			
		ИначеЕсли СтрНачинаетсяС(ИмяФайла, ЭлементНастройки.Ключ) Тогда
			
			НайденнаяНастройка = ЭлементНастройки.Значение;
			
		Иначе
			// ничего
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат НайденнаяНастройка;
	
КонецФункции