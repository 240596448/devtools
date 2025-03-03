#Использовать "."
#Использовать "../core"
#Использовать cli

Процедура ВыполнитьПриложение()

	Приложение = Новый КонсольноеПриложение("devtools", "Помощник для разработки в конфигураторе 1С:Предприятия и Git");

	Приложение.Версия("v version", ПараметрыПриложения.ВерсияПриложения());

	Приложение.Опция("config", "", "путь к файлу параметров информационной базы в формате json")
			.Обязательный(Ложь)
			.ВОкружении("DT_CONFIG");

	Приложение.Опция("logfile", "", "файл журнала лога")
			.Обязательный(Ложь)
			.ВОкружении("DT_LOGFILE");

	Приложение.ДобавитьКоманду("test", "Тест чтения настроек", Новый ТестНастроек);

	Приложение.ДобавитьКоманду("dump", "Выгрузка объектов конфигурации в файлы", Новый КомандаВыгрузкаОбъектовВИсходники);
	Приложение.ДобавитьКоманду("load", "Загрузка объектов конфигурации из файлов", Новый КомандаЗагрузкаОбъектовИзИсходников);
	Приложение.ДобавитьКоманду("label", "Создать ""метку"" (запомнить хэш коммита как последний успешно синхронизированный с конфигурацией ИБ)", Новый КомандаУстановитьМетку);
	Приложение.ДобавитьКоманду("sync", "Перенос изменений из git в хранилище", Новый КомандаСинхронизацияСХранилищем);

	Приложение.УстановитьДействиеПередВыполнением(ЭтотОбъект, "ПередВыполнениемКоманды");

	Приложение.Запустить(АргументыКоманднойСтроки);

КонецПроцедуры

Процедура ПередВыполнениемКоманды(Знач Команда) Экспорт

	ЖурналЛога = Команда.ЗначениеОпции("logfile");
	ПараметрыПриложения.Лог(ЖурналЛога);
	
	ПутьККонфигурацииНастроек = Команда.ЗначениеОпции("config");
	ПараметрыПриложения.УстановитьНастройки(ПутьККонфигурацииНастроек);

КонецПроцедуры


Попытка
	ВыполнитьПриложение();
Исключение
	Лог = ПараметрыПриложения.Лог();
	Лог.КритичнаяОшибка(ОписаниеОшибки());
	Лог.Закрыть();
	ЗавершитьРаботу(1);
КонецПопытки;
