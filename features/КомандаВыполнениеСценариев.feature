# language: ru

Функциональность: Выполнение прекоммита

Как разработчик
Я хочу быть уверенным, что precommit4onec корректно обрабатывает выполнение сценариев для каталога

Контекст:
	Допустим Я очищаю параметры команды "oscript" в контексте 
		И я очищаю параметры команды "git" в контексте
		И Я устанавливаю кодировку вывода "utf-8" команды "git"
		И я включаю отладку лога с именем "oscript.app.precommit4onec"
		И я создаю временный каталог и запоминаю его как "КаталогРепозиториев"
		И я переключаюсь во временный каталог "КаталогРепозиториев"
		И я создаю новый репозиторий "rep1" в каталоге "КаталогРепозиториев" и запоминаю его как "РабочийКаталог"
		И я установил рабочий каталог как текущий каталог
		
Сценарий: Разбор отчетов, обработок, конфигурации на исходники.
	Когда Я копирую файл "tests/fixtures/demo/DemoОбработка.epf" в каталог репозитория "РабочийКаталог"
		И я копирую файл "tests/fixtures/demo/DemoОтчет.erf" в каталог репозитория "РабочийКаталог"
		И я копирую файл "tests/fixtures/demo/DemoРасширение.cfe" в каталог репозитория "РабочийКаталог"
		И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os exec-rules <РабочийКаталог> -source-dir ."
	Тогда В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ\Ext\Form\Module.bsl"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ\Ext\Form\form"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Templates\ОсновнаяСхемаКомпоновкиДанных.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Templates\ОсновнаяСхемаКомпоновкиДанных\Ext\Template.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяОФ\Ext\Form.bin"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяУФ.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "erf\DemoОтчет\DemoОтчет\Forms\ОсновнаяУФ\Ext\Form.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form.bin"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяУФ.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяУФ\Ext\Form.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form\Module.bsl"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "epf\DemoОбработка\DemoОбработка\Forms\ОсновнаяОФ\Ext\Form\form"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\ConfigDumpInfo.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\Configuration.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\CommonModules\DemoРасш_Demo.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\CommonModules\DemoРасш_Demo\Ext\Module.bsl"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\Subsystems\DemoРасш_Demo.xml"
		И В каталоге "." репозитория "РабочийКаталог" есть файл "cfe\DemoРасширение\Languages\Русский.xml"

Сценарий: Успешный коммит в репозиторий
	Когда Я копирую файл "tests\fixtures\ПроверкаДублейПроцедурПоложительныйТест.bsl" в каталог репозитория "РабочийКаталог"
	И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os exec-rules <РабочийКаталог> -source-dir ."
	Тогда Вывод команды "oscript" не содержит "обнаружены неуникальные имена методов"

Сценарий: Прекоммит вывел ошибку о неуникальных именах
	Когда Я копирую файл "tests\fixtures\ПроверкаДублейПроцедурНегативныйТест.bsl" в каталог репозитория "РабочийКаталог"
	И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os exec-rules <РабочийКаталог> -source-dir ."
	Тогда Вывод команды "oscript" содержит "обнаружены неуникальные имена методов"

Сценарий: Прекоммит использует локальные настройки репозитория вместо глобальных
	Когда Я копирую каталог "localscenario" из каталога "tests\fixtures" проекта в рабочий каталог
		И Я копирую файл "v8config.json" из каталога "tests\fixtures" проекта в рабочий каталог
		И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os exec-rules <РабочийКаталог> -source-dir ."
		И Я сообщаю вывод команды "oscript"
	Тогда Вывод команды "oscript" содержит "Используем локальные настройки"

Сценарий: Разбор конфигурации на исходники с последующим применением правил к распакованным модулям.
	Когда Я копирую каталог "src" из каталога "tests/fixtures/cf-common-forms" проекта в рабочий каталог
		И я копирую файл "v8config.json" из каталога "tests/fixtures/cf-common-forms" проекта в рабочий каталог
		И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os exec-rules ."
	Тогда В каталоге "src\Catalogs\Справочник1\Forms\ФормаЭлемента\Ext\Form" репозитория "РабочийКаталог" есть файл "Module.bsl"
	И файл "src\Catalogs\Справочник1\Forms\ФормаЭлемента\Ext\Form\Module.bsl" в рабочем каталоге содержит
	"""
		Процедура ПриОткрытии()
			
			Сообщить("Hello, world!");
			
			Условие = Истина;
			
			Если Условие Тогда
				Возврат;
			КонецЕсли;
			
		КонецПроцедуры
	"""
