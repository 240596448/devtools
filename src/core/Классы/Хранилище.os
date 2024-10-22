
Перем Инициализирован;

Перем Путь Экспорт;
Перем Пользователь Экспорт;
Перем Пароль Экспорт;

Процедура ОбработкаПолученияПредставления(Строка, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	Если НЕ Инициализирован Тогда
		Строка = "<объект не инициализирован>";
	ИначеЕсли ЗначениеЗаполнено(Пароль) Тогда
		Строка = СтрШаблон("путь %1, пользователь %2, пароль %3", Путь, Пользователь, "***");
	Иначе
		Строка = СтрШаблон("путь %1, пользователь %2", Путь, Пользователь);
	КонецЕсли;

КонецПроцедуры

Процедура ПриСозданииОбъекта(СтруктураНастройки = Неопределено)

	Инициализирован = СтруктураНастройки <> Неопределено;
	Если НЕ Инициализирован Тогда
		Возврат;
	КонецЕсли;

	Хранилище = Новый Структура();
	Хранилище.Вставить("Путь",         "");
	Хранилище.Вставить("Пользователь", "");
	Хранилище.Вставить("Пароль",       "");

	ЗаполнитьЗначенияСвойств(Хранилище, СтруктураНастройки);

	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Хранилище);

КонецПроцедуры
