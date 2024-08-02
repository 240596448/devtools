#Использовать gitrunner
#Использовать v8runner
#Использовать fs

Перем Лог;
Перем Параметры;
Перем Хранилище;
Перем УправлениеКонфигуратором;
Перем Репозиторий;
Перем ИмяУдаленногоРепозитория;
Перем ИмяВеткиРазработки;
Перем ИмяВеткиХранилища;

Перем СоотвествиеИмен;

Процедура ПриСозданииОбъекта()
	
	Лог = ПараметрыПриложения.Лог();
	Параметры = ПараметрыПриложения.ПолучитьНастройки();

	Хранилище = Параметры.Хранилище;
	Репозиторий = Параметры.Репозиторий;
	Репозиторий.УстановитьРежимВыводаСообщений(Истина);

	База = Параметры.База;
	УправлениеКонфигуратором = Новый УправлениеКонфигуратором();
	УправлениеКонфигуратором.ПутьКПлатформе1С(Параметры.ПутьКПлатформе);
	УправлениеКонфигуратором.УстановитьКонтекст("/F"+База.ПутьКФайлуБазы, База.Пользователь, База.Пароль);
	УправлениеКонфигуратором.УстановитьИмяФайлаСообщенийПлатформы("temp\logs\Хранилище.log");

	СоотвествиеИмен = СоответсвиеИменГитХран();

КонецПроцедуры

Процедура УстановитьИмяУдаленогоРепозитория(ИмяРепозитория) Экспорт
	ИмяУдаленногоРепозитория = ИмяРепозитория;
КонецПроцедуры

Процедура УстановитьВеткуРазработки(ИмяВетки) Экспорт
	ИмяВеткиРазработки = ИмяВетки;
КонецПроцедуры

Процедура УстановитьВеткуХранилища(ИмяВетки) Экспорт
	ИмяВеткиХранилища = ИмяВетки;
КонецПроцедуры

Процедура ОтменаВыполнения() Экспорт
	
	// отменить мерж
	Лог.Информация("Прерывание мержа");
	Репозиторий.ВыполнитьГитКоманду("git merge --abort", 128);

	// отменить захват в хранилише
	ФайлСоСпискомОбъектов = ИмяФайлаОбъектовХранилища();
	Если ФС.ФайлСуществует(ФайлСоСпискомОбъектов) Тогда
		Лог.Информация("Отмена захвата в хранилище по списку из файла");
		УправлениеКонфигуратором.ОтменитьЗахватОбъектовВХранилище(Хранилище.Путь, Хранилище.Пользователь, Хранилище.Пароль, ФайлСоСпискомОбъектов);
	Иначе
		Лог.Информация("Отмена захвата в хранилище рекурсивно");
		УправлениеКонфигуратором.ОтменитьЗахватОбъектовВХранилище(Хранилище.Путь, Хранилище.Пользователь, Хранилище.Пароль);
	КонецЕсли;
	Сообщить(УправлениеКонфигуратором.ВыводКоманды());

КонецПроцедуры
Процедура ВыполнитьСинхронизациюИзВеткиРазработкиВВеткуХранилищем() Экспорт

	сткДанныеСтатуса = Репозиторий.ДанныеСтатуса();

	Если сткДанныеСтатуса.ЕстьКонфликт Тогда
		Текст = "Есть конфликт";
		Лог.Ошибка(Текст);
		ВызватьИсключение Текст;
	ИначеЕсли сткДанныеСтатуса.ЕстьИзменения Тогда
		Лог.Информация("Есть изменения в Work tree");
		Возврат;
	КонецЕсли;

	ГитРепозиторий = Репозиторий.ГитРепозиторий;

	// git checkout gitsync && git pull
	Лог.Информация("Переход на ветку %1 и обновление", ИмяВеткиХранилища);
	ГитРепозиторий.ПерейтиВВетку(ИмяВеткиХранилища);
	ГитРепозиторий.Получить();

	// git fetch origin develop:develop
	Лог.Информация("Подтягивание ветки %1", ИмяВеткиРазработки);
	Репозиторий.ВыполнитьГитКоманду(СтрШаблон("git fetch %1 %2:%2", ИмяУдаленногоРепозитория, ИмяВеткиРазработки));

	// начинаем мерж
	Лог.Информация("Слияние ветки %1 в ветку %2", ИмяВеткиРазработки, ИмяВеткиХранилища);
	КомандаГит = СтрШаблон("git merge %1 --no-ff --no-commit --message ""Перенос основной ветки %1 в ветку хранилища 1С %2""", ИмяВеткиРазработки, ИмяВеткиХранилища);
	Репозиторий.ВыполнитьГитКоманду(КомандаГит);
	
	Лог.Информация("отмена слияния служебных файлов");
	Репозиторий.ВыполнитьГитКоманду("git checkout HEAD src/VERSION src/AUTHORS .gitignore");
	//Репозиторий.ВыполнитьГитКоманду("git reset tools/* && git clean -f tools/*");

	сткДанныеСтатуса = Репозиторий.ДанныеСтатуса();
	Если сткДанныеСтатуса.ЕстьКонфликт Тогда
		Текст = "Есть конфликт. Требуется разрешить конфликт вручную";
		Лог.Ошибка(Текст);
		ВызватьИсключение "
			|Разрешите конфликт и запустите команду повторно с ключем --continue";

	ИначеЕсли НЕ сткДанныеСтатуса.ЕстьИзменения Тогда
		Лог.Информация("Нет данных к синхронизации");
		Возврат;
		
	КонецЕсли;

	ПродолжениеПослеСлияния();

КонецПроцедуры

Процедура ПродолжениеПослеСлияния() Экспорт

	// обновление базы
	ОбновитьБазуИзХранилища();

	// получение дифа 
	СписокФайлов = СформироватьСписокИзмененныхФайловГитКПереносуВХранилище();
	Если НЕ ЗначениеЗаполнено(СписокФайлов) Тогда
		Лог.Информация("В ветке %1 нет изменений к переносу в хранилище", ИмяВеткиРазработки);
		Возврат;
	Иначе
		Лог.Информация("В ветке %1 находится %2 измененных файлов", ИмяВеткиРазработки, СписокФайлов.Количество());
	КонецЕсли;

	// захват объектов в хранилище
	ОбъектыХранилища = ПолучитьИменаХранилища(СписокФайлов);
	Если НЕ ЗначениеЗаполнено(ОбъектыХранилища) Тогда
		Лог.Информация("Не определено ни одного объекта 1С к переносу в хранилище");
		Возврат;
	Иначе
		Лог.Информация("Определено %1 объектов 1С к загрузке в хранилище", ОбъектыХранилища.Количество());
	КонецЕсли;
	ТекстФайлаОбъектов = СформироватьТекстКонфигурационногоФайлаОбъектовХранилища1С(ОбъектыХранилища);
	ФайлСоСпискомОбъектов = ИмяФайлаОбъектовХранилища();
	Служебные.ЗаписатьВФайл(ФайлСоСпискомОбъектов, ТекстФайлаОбъектов);

	УправлениеКонфигуратором.ЗахватитьОбъектыВХранилище(Хранилище.Путь, Хранилище.Пользователь, Хранилище.Пароль, ФайлСоСпискомОбъектов);
	Сообщить(УправлениеКонфигуратором.ВыводКоманды());

	// загрузка объектов базу хранилища
	Лог.Информация("Загрузка измененных объектов в хранилище");
	МенеджерЗагрузки = Новый МенеджерЗагрузки();
	ОбъектыЗагрузки = Новый Массив();
	ОбъектыЗагрузки.Добавить("HEAD");
	МенеджерЗагрузки.Загрузить(ОбъектыЗагрузки);

	// Коммит в хранилище
	КомандаГит = СтрШаблон("git log %1..%2 --pretty=oneline --merges --abbrev-commit", ИмяВеткиХранилища, ИмяВеткиРазработки);
	КомментарийДляХранилища = Репозиторий.ВыполнитьГитКоманду(КомандаГит);
	УправлениеКонфигуратором.ПоместитьИзмененияОбъектовВХранилище(Хранилище.Путь, Хранилище.Пользователь, Хранилище.Пароль, ФайлСоСпискомОбъектов, КомментарийДляХранилища);
	Сообщить(УправлениеКонфигуратором.ВыводКоманды());

	// заканчиваем мерж
	Лог.Информация("Завершение мержа ветки %1 в ветку %2", ИмяВеткиРазработки, ИмяВеткиХранилища);
	Репозиторий.ВыполнитьГитКоманду("git merge --continue");

КонецПроцедуры

Функция ИмяФайлаОбъектовХранилища()
	Возврат "temp/СписокОбъектовХранилиза1С.xml";
КонецФункции

Процедура ОбновитьБазуИзХранилища()
	
	Лог.Информация("обновляем базу 1С из хранилища...");
	
	//УправлениеКонфигуратором.ИсключениеПриОшибкеВыполненияКоманды(Ложь);
	УправлениеКонфигуратором.ОбновитьКонфигурациюБазыДанныхИзХранилища(Хранилище.Путь, Хранилище.Пользователь, Хранилище.Пароль);
	//УправлениеКонфигуратором.ИсключениеПриОшибкеВыполненияКоманды(Истина);

	Сообщить(УправлениеКонфигуратором.ВыводКоманды());

КонецПроцедуры

Функция СформироватьСписокИзмененныхФайловГитКПереносуВХранилище()

	Лог.Информация("получаем список файлов для синхронизации");
	ВыводКоманды = Репозиторий.ВыполнитьГитКоманду("git diff --name-only HEAD");
	СписокОбъектовГит = СтрРазделить(ВыводКоманды, Символы.ПС, Ложь);
	Возврат СписокОбъектовГит;

КонецФункции

Функция Мета(ИмяМета)
	НовоеИмя = СоотвествиеИмен[ИмяМета];
	Если ЗначениеЗаполнено(НовоеИмя) Тогда
		Возврат НовоеИмя;
	Иначе
		Возврат ИмяМета;
	КонецЕсли;
КонецФункции

Функция ИмяБезРасширения(Имя)
	части = СтрРазделить(Имя, ".", Ложь);
	Возврат части[0];
КонецФункции

Функция ПолучитьИменаХранилища(мИменаФайлов)
	
	сОбъектыХранилища = Новый Соответствие();
	
	Для Каждого ИмяФайла Из мИменаФайлов Цикл
		Если ПустаяСтрока(ИмяФайла) Тогда
			Продолжить;
		ИначеЕсли ИмяФайла = "src/AUTHORS"
			Или ИмяФайла = "src/VERSION"
			Или ИмяФайла = "src/ConfigDumpInfo.xml" Тогда
			Продолжить;
		КонецЕсли;

		Рекурсивно = Ложь;

		мЧастиИмени = СтрРазделить(СокрЛП(ИмяФайла), "/");

		Если мЧастиИмени.Количество() < 2 Тогда
			Лог.Предупреждение("Неизвестный файл: %1", ИмяФайла);
			Продолжить;
		ИначеЕсли мЧастиИмени.Количество() = 2 Тогда
			Если мЧастиИмени[1] = "Configuration.xml" Тогда
				Объект = "root";
			Иначе
				Лог.Предупреждение("Неизвестный файл: %1", ИмяФайла);
				Продолжить;
			КонецЕсли;
		Иначе
			Имя = мЧастиИмени[2];

			Если мЧастиИмени[1] = "Ext"
				Или мЧастиИмени[1] = "Configuration.xml" Тогда
				Объект = "root";
			ИначеЕсли мЧастиИмени.Количество() = 3 Тогда
				Объект = СтрШаблон("%1.%2", Мета(мЧастиИмени[1]), ИмяБезРасширения(Имя));
			ИначеЕсли мЧастиИмени[3] = "Ext" 
				Или мЧастиИмени[3] = "Commands" Тогда
				Объект = СтрШаблон("%1.%2", Мета(мЧастиИмени[1]), Имя);
			ИначеЕсли ЗначениеЗаполнено(Мета(мЧастиИмени[3])) Тогда
			 	Объект = СтрШаблон("%1.%2.%3.%4", Мета(мЧастиИмени[1]), Имя, Мета(мЧастиИмени[3]), ИмяБезРасширения(мЧастиИмени[4]));
			Иначе
				Лог.Предупреждение("Неизвестный файл: %1", ИмяФайла);
			КонецЕсли;

		КонецЕсли;

		сОбъектыХранилища.Вставить(Объект, Рекурсивно);

	КонецЦикла;

	Возврат сОбъектыХранилища;

КонецФункции

Функция СформироватьТекстКонфигурационногоФайлаОбъектовХранилища1С(ОбъектыХранилища)
	
	МассивОбъектов = Новый Массив();
	МассивОбъектов.Добавить("<Objects xmlns=""http://v8.1c.ru/8.3/config/objects"" version=""1.0""> ");
	
	Если ОбъектыХранилища["root"] <> Неопределено Тогда
		МассивОбъектов.Добавить(СтрШаблон("    <Configuration includeChildObjects = ""%1""/>", ?(ОбъектыХранилища["root"], "true", "false")));
	КонецЕсли;
	
	Для каждого КЗ Из ОбъектыХранилища Цикл
		Если КЗ.Ключ <> "root" Тогда
			МассивОбъектов.Добавить(СтрШаблон("    <Object fullName = ""%1"" includeChildObjects= ""%2"" />", КЗ.Ключ, ?(КЗ.Значение, "true", "false")));
		КонецЕсли;
	КонецЦикла;

	МассивОбъектов.Добавить("</Objects>");

	Возврат СтрСоединить(МассивОбъектов, Символы.ПС);

КонецФункции

Функция СоответсвиеИменГитХран()
	
	СоотвествиеИмен = Новый Соответствие();

	СоотвествиеИмен.Вставить("AccountingRegisters",         "РегистрБухгалтерии"          );
	СоотвествиеИмен.Вставить("AccumulationRegisters",       "РегистрНакопления"           );
	СоотвествиеИмен.Вставить("Bots",                        "Боты"                        );
	СоотвествиеИмен.Вставить("BusinessProcesses",           "БизнесПроцесс"               );
	СоотвествиеИмен.Вставить("CalculationRegisters",        "РегистрРасчета"              );
	СоотвествиеИмен.Вставить("Catalogs",                    "Справочник"                  );
	СоотвествиеИмен.Вставить("ChartsOfAccounts",            "ПланСчетов"                  );
	СоотвествиеИмен.Вставить("ChartsOfCalculationTypes",    "ПланВидовРасчета"            );
	СоотвествиеИмен.Вставить("ChartsOfCharacteristicTypes", "ПланВидовХарактеристик"      );
	СоотвествиеИмен.Вставить("CommandGroups",               "ГруппаКоманд"                );
	СоотвествиеИмен.Вставить("CommonAttributes",            "ОбщийРеквизит"               );
	СоотвествиеИмен.Вставить("CommonCommands",              "ОбщаяКоманда"                );
	СоотвествиеИмен.Вставить("CommonForms",                 "ОбщаяФорма"                  );
	СоотвествиеИмен.Вставить("CommonModules",               "ОбщийМодуль"                 );
	СоотвествиеИмен.Вставить("CommonPictures",              "ОбщаяКартинка"               );
	СоотвествиеИмен.Вставить("CommonTemplates",             "ОбщийМакет"                  );
	СоотвествиеИмен.Вставить("Constants",                   "Константа"                   );
	СоотвествиеИмен.Вставить("DataProcessors",              "Обработка"                   );
	СоотвествиеИмен.Вставить("DefinedTypes",                "ОпределяемыйТип"             );
	СоотвествиеИмен.Вставить("DocumentJournals",            "ЖурналДокументов"            );
	СоотвествиеИмен.Вставить("Documents",                   "Документ"                    );
	СоотвествиеИмен.Вставить("Enums",                       "Перечисление"                );
	СоотвествиеИмен.Вставить("EventSubscriptions",          "ПодпискаНаСобытие"           );
	СоотвествиеИмен.Вставить("ExternalDataSources",         "ВнешнийИсточникДанных"       );
	СоотвествиеИмен.Вставить("ExchangePlans",               "ПланОбмена"                  );
	СоотвествиеИмен.Вставить("FilterCriteria",              "КритерийОтбора"              );
	СоотвествиеИмен.Вставить("FunctionalOptions",           "ФункциональнаяОпция"         );
	СоотвествиеИмен.Вставить("FunctionalOptionsParameters", "ПараметрФункциональныхОпций" );
	СоотвествиеИмен.Вставить("HTTPServices",                "HTTPСервис"                  );
	СоотвествиеИмен.Вставить("InformationRegisters",        "РегистрСведений"             );
	СоотвествиеИмен.Вставить("IntegrationServices",         "СервисИнтеграции"            );
	СоотвествиеИмен.Вставить("Languages",                   "Язык"                        );
	СоотвествиеИмен.Вставить("Reports",                     "Отчет"                       );
	СоотвествиеИмен.Вставить("Roles",                       "Роль"                        );
	СоотвествиеИмен.Вставить("ScheduledJobs",               "РегламентноеЗадание"         );
	СоотвествиеИмен.Вставить("Sequences",                   "Последовательность"          );
	СоотвествиеИмен.Вставить("SessionParameters",           "ПараметрСеанса"              );
	СоотвествиеИмен.Вставить("SettingsStorages",            "ХранилищеНастроек"           );
	СоотвествиеИмен.Вставить("StyleItems",                  "ЭлементСтиля"                );
	СоотвествиеИмен.Вставить("Styles",                      "Стиль"                       );
	СоотвествиеИмен.Вставить("Subsystems",                  "Подсистема"                  );
	СоотвествиеИмен.Вставить("Tasks",                       "Задача"                      );
	СоотвествиеИмен.Вставить("WebServices",                 "WebСервис"                   );
	СоотвествиеИмен.Вставить("XDTOPackages",                "ПакетXDTO"                   );

	СоотвествиеИмен.Вставить("Forms",          "Форма"   );
	СоотвествиеИмен.Вставить("Recalculations", "Пересчет");
	СоотвествиеИмен.Вставить("Templates",      "Макет"   );
	СоотвествиеИмен.Вставить("Cubes",          "Куб"     );
	СоотвествиеИмен.Вставить("Tables",         "Таблица" );

	Возврат СоотвествиеИмен;
	
КонецФункции

