Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.Опция("origin", "origin", "синоним удаленного репозитория")
			.ВОкружении("DT_ORIGIN")
			.ТСтрока();

	Команда.Опция("dev", "develop", "основная ветка разработки в git")
			.ВОкружении("DT_BRANCH_DEVELOP")
			.ТСтрока();

	Команда.Опция("sync", "gitsync", "ветка синхронизации 1С хранилища")
			.ВОкружении("DT_BRANCH_GITSYNC")
			.ТСтрока();

	Команда.Опция("cont continue", Ложь, "продолжить выполнение после зазрешения конфликтов")
			.Флаг();

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	Лог = ПараметрыПриложения.Лог();
	
	ИмяУдаленногоРепозитория         = Команда.ЗначениеОпции("origin");
	ИмяОсновнойВеткиРазработки       = Команда.ЗначениеОпции("dev");
	ИмяВеткиСинхронизацииСХранилищем = Команда.ЗначениеОпции("sync");
	ПродолжитьПослеКонфликта         = Команда.ЗначениеОпции("continue");

	ЗамерНачало = ТекущаяДата();
	Лог.Информация("Команда: Перенос изменений из репозитория в хранилище");
	Лог.Информация("Начало: %1", ЗамерНачало);

	МенеджерСинхронизацииСХранилищем = Новый МенеджерСинхронизацииСХранилищем();
	
	МенеджерСинхронизацииСХранилищем.УстановитьИмяУдаленогоРепозитория(ИмяУдаленногоРепозитория);
	МенеджерСинхронизацииСХранилищем.УстановитьВеткуРазработки(ИмяОсновнойВеткиРазработки);
	МенеджерСинхронизацииСХранилищем.УстановитьВеткуХранилища(ИмяВеткиСинхронизацииСХранилищем);
	
	Если ПродолжитьПослеКонфликта Тогда
		МенеджерСинхронизацииСХранилищем.ПродолжениеПослеСлияния();
	Иначе
		Результат = МенеджерСинхронизацииСХранилищем.ВыполнитьСинхронизациюИзВеткиРазработкиВВеткуХранилищем();
	КонецЕсли;

	ЗамерОкончание = ТекущаяДата();
	Лог.Информация("Окончание: %1", ЗамерОкончание);
	
	ДлительностьСекунд = ЗамерОкончание - ЗамерНачало;
	Лог.Информация("Время выполнения: %1:%2 мин", Цел(ДлительностьСекунд / 60), ДлительностьСекунд % 60);

КонецПроцедуры
