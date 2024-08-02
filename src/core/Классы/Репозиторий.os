#Использовать gitrunner

Перем Инициализирован;
Перем Путь Экспорт;
Перем Исходники Экспорт;

Перем ГитРепозиторий Экспорт;
Перем Лог;

Перем РежимВыводаСообщений;

Процедура ОбработкаПолученияПредставления(Строка, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	Если НЕ Инициализирован Тогда
		Строка = "<объект не инициализирован>";
	Иначе
		Строка = СтрШаблон("git path %1%3(%2)", Путь, Исходники, ПолучитьРазделительПути());
	КонецЕсли;

КонецПроцедуры

Процедура ПриСозданииОбъекта(СтруктураНастройки = Неопределено)

	РежимВыводаСообщений = Ложь;

	Инициализирован = СтруктураНастройки <> Неопределено;
	Если НЕ Инициализирован Тогда
		Возврат;
	КонецЕсли;

	Лог = ПараметрыПриложения.Лог();

	Репозиторий = Новый Структура();
	Репозиторий.Вставить("Путь",      "");
	Репозиторий.Вставить("Исходники", "src");

	ЗаполнитьЗначенияСвойств(Репозиторий, СтруктураНастройки);

	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Репозиторий);

	Служебные.УбратьКонцевойСлеш(Путь);
	Служебные.УбратьКонцевойСлеш(Исходники);

	Служебные.ПривестиКСлешамСистемы(Путь);
	Служебные.ПривестиКСлешамСистемы(Исходники);

	ГитРепозиторий = Новый ГитРепозиторий;
	ГитРепозиторий.УстановитьРабочийКаталог(Путь);

КонецПроцедуры

Функция ИмяФайлаНастройкиПоддержки() Экспорт
	Возврат "Ext" + ПолучитьРазделительПути() + "ParentConfigurations.bin";
КонецФункции

Функция ПолныйПутьКИсходникам() Экспорт
	Возврат ОбъединитьПути(Путь, Исходники);
КонецФункции

Функция ХэшТекущейВетки() Экспорт
	КоманднаяСтрока = "git rev-parse --short HEAD";
	Хэш = ВыполнитьКоманду(КоманднаяСтрока);
	Лог.Отладка("Хэш текущей ветки: %1", Хэш);
	Возврат Хэш;
КонецФункции

Процедура ЗаписатьХэшПоследнегоЗагруженногоКоммита() Экспорт

	Хэш = ХэшТекущейВетки();

	ИмяФайла = ФайлПредыдущегоГитКоммита().ПолноеИмя;

	Служебные.ЗаписатьВФайл(ИмяФайла, Хэш);

	Лог.Информация("Хэш коммита %1 отмечен как ""синхронизированная конфигурация"". Хэш-файл: %2", Хэш, ИмяФайла);

КонецПроцедуры

Функция ФайлПредыдущегоГитКоммита(Знач Расположение = "temp")
	Каталог = ОбъединитьПути(Путь, Расположение);
	ФС.ОбеспечитьКаталог(Каталог);
	Возврат Новый Файл(ОбъединитьПути(Каталог, ИмяФайлаПредыдущегоГитКоммита()));
КонецФункции

Функция ИмяФайлаПредыдущегоГитКоммита()
	Возврат "lastUploadedCommit.txt";
КонецФункции

Функция ПолучитьИзмененныеФайлы() Экспорт
	Хэш = ПолучитьХэшПоследнегоЗагруженногоКоммита();
	Если ЗначениеЗаполнено(Хэш) Тогда
		Возврат ПолучитьСписокДоКоммита(Хэш);
	Иначе
		Возврат "";
	КонецЕсли;
КонецФункции

Функция ПолучитьХэшПоследнегоЗагруженногоКоммита() Экспорт

	ИмяФайла = ФайлПредыдущегоГитКоммита().ПолноеИмя;

	Если Не ФС.ФайлСуществует(ИмяФайла) Тогда
		Возврат "";
	КонецЕсли;

	Хэш = Служебные.ПрочитатьИзФайла(ИмяФайла);

	Возврат СокрЛП(Хэш);

КонецФункции

Функция ФайлВСпискеИсключений(ПутьКФайлу)

	Возврат СтрЗаканчиваетсяНа(ПутьКФайлу, "ConfigDumpInfo.xml")
		Или СтрЗаканчиваетсяНа(ПутьКФайлу, "ConfigID.xml")
		Или СтрЗаканчиваетсяНа(ПутьКФайлу, "AUTHORS")
		Или СтрЗаканчиваетсяНа(ПутьКФайлу, "VERSION")
		Или СтрЗаканчиваетсяНа(ПутьКФайлу, "dumplist.txt")
		Или СтрЗаканчиваетсяНа(ПутьКФайлу, "ParentConfigurations_mod.bin")
		Или СтрЗаканчиваетсяНа(ПутьКФайлу, ИмяФайлаПредыдущегоГитКоммита())
		;

КонецФункции

Функция ДополнитьПутиГит(МассивПутейГит)
	мТекст = Новый Массив();
	ПолныйПутьКИсходникам = ПолныйПутьКИсходникам() + ПолучитьРазделительПути();
	Для Каждого Стр Из МассивПутейГит Цикл
		Стр = СокрЛП(Стр);
		Если ФайлВСпискеИсключений(Стр) Тогда
			Продолжить;
		КонецЕсли;
		Файл = Новый Файл(ОбъединитьПути(Путь, Стр));
		Если СтрНачинаетсяС(Файл.ПолноеИмя, ПолныйПутьКИсходникам) Тогда
			ПутьВИсходниках = СтрЗаменить(Файл.ПолноеИмя, ПолныйПутьКИсходникам, "");
			мТекст.Добавить(ПутьВИсходниках);
		КонецЕсли;
	КонецЦикла;
	Возврат мТекст;
КонецФункции


Функция ЭтоХэшКоммита(Хэш) Экспорт

	Если НЕ (СтрДлина(Хэш) = 10 Или СтрДлина(Хэш) = 40) Тогда
		Возврат Ложь;
	КонецЕсли;

	КоманднаяСтрока = "git log --pretty=format:%H";
	Вывод = ВыполнитьКомандуВМассив(КоманднаяСтрока);
	Для Каждого Стр Из Вывод Цикл
		Если СтрНачинаетсяС(Стр, Хэш) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ЭтоТэг(Тэг) Экспорт

	КоманднаяСтрока = "git tag --list --no-color";
	Вывод = ВыполнитьКомандуВМассив(КоманднаяСтрока);
	Для Каждого Стр Из Вывод Цикл
		Если СтрНачинаетсяС(Стр, Тэг) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ЭтоВетка(ИмяВетки) Экспорт

	Если ВРег(СокрЛП(ИмяВетки)) = "HEAD" Тогда
		Возврат Истина;
	КонецЕсли;
	
	КоманднаяСтрока = "git branch --verbose --no-color";
	Вывод = ВыполнитьКомандуВМассив(КоманднаяСтрока);
	Для Каждого Стр Из Вывод Цикл
		Стр = Сред(Стр, 3);
		Стр = Сред(Стр, 1, СтрНайти(Стр, " ") - 1);
		Если Стр = ИмяВетки Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ДанныеСтатуса() Экспорт
	ДанныеСтатуса = ГитРепозиторий.ДанныеСтатуса();
	
	Статус = ДанныеСтатуса.Получить();
	Таблица = ДанныеСтатуса.ТаблицаИзменений();

	стк = Новый Структура(
		"Статус, Таблица, ЕстьИзменения,ЕстьКонфликт", 
		Статус, Таблица, Ложь, Ложь);

	стк.ЕстьИзменения = Таблица.Количество() > 0;

	Для Каждого Стр Из Таблица Цикл
		Если ЗначениеЗаполнено(Стр.СостояниеВИндексе)
			И ЗначениеЗаполнено(Стр.СостояниеВДереве) Тогда
			стк.ЕстьКонфликт = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат стк;

КонецФункции

Функция ПолучитьСписокИзмененныхФайлов() Экспорт
	КоманднаяСтрока ="git status --porcelain";
	Вывод = ВыполнитьКомандуВМассив(КоманднаяСтрока);
	Массив = Новый Массив;
	Для каждого Стр Из Вывод Цикл
		части = СтрРазделить(Стр, " ", Ложь);
		ПутьКФайлу = СокрЛП(части[1]);
		Массив.Добавить(ПутьКФайлу);
	КонецЦикла;
	Возврат ЗаписатьОбъектыВФайл(НормализоватьИмена(ДополнитьПутиГит(Массив)));
КонецФункции

Функция ПолучитьСписокПоКоличествуКоммитов(СмещениеПервогоКоммита, СмещениеВторогоКоммитаИлиСсылка = "") Экспорт
	Если ЗначениеЗаполнено(СмещениеВторогоКоммитаИлиСсылка) Тогда
		КоманднаяСтрока = СтрШаблон("git diff --name-only HEAD~%1 HEAD~%2", СмещениеПервогоКоммита, СмещениеВторогоКоммитаИлиСсылка);
	Иначе
		КоманднаяСтрока = СтрШаблон("git diff --name-only HEAD~%1", СмещениеПервогоКоммита);
	КонецЕсли;
	Вывод = ВыполнитьКомандуВМассив(КоманднаяСтрока);
	Возврат ЗаписатьОбъектыВФайл(НормализоватьИмена(ДополнитьПутиГит(Вывод)));
КонецФункции

Функция ПолучитьСписокДоКоммита(Хэш, Хэш2 = "") Экспорт
	КоманднаяСтрока = СтрШаблон("git diff --name-only %1 %2", Хэш, Хэш2);
	Вывод = ВыполнитьКомандуВМассив(КоманднаяСтрока);
	Если НЕ ЗначениеЗаполнено(Вывод) Тогда
		Возврат "";
	Иначе
		Возврат ЗаписатьОбъектыВФайл(НормализоватьИмена(ДополнитьПутиГит(Вывод)));
	КонецЕсли;
КонецФункции

Функция СформироватьСписок(мОбъекты) Экспорт
	
	мСписокФайлов = Новый Массив();

	Для каждого Объект Из мОбъекты Цикл
		КаталогПоиска = ПолныйПутьКИсходникам();
		ПозПервогоСлеша = СтрНайти(Объект, "/");
		Если ПозПервогоСлеша = 0 Тогда
			ОбъектПоиска = Объект;
			ХвостОбъекта = "";
		Иначе
			ОбъектПоиска = Лев(Объект, ПозПервогоСлеша - 1);
			ХвостОбъекта = Сред(Объект, ПозПервогоСлеша + 1);
		КонецЕсли;

		Пока Истина Цикл

			Сообщить(СтрШаблон("Ищем %1 в каталоге %2", ОбъектПоиска, КаталогПоиска));
			мНайденныеФайлы = НайтиФайлы(КаталогПоиска, ОбъектПоиска, Истина);

			Если мНайденныеФайлы.Количество() = 0 Тогда
				ВызватьИсключение СтрШаблон("Объект %1 не найден в репозитории", ОбъектПоиска);
			ИначеЕсли мНайденныеФайлы.Количество() > 1 И СтрНайти(ОбъектПоиска, "*") = 0 Тогда
				сч = 10;
				Для Каждого НайденныйФайл Из мНайденныеФайлы Цикл
					мСписокФайлов.Добавить(НайденныйФайл.ПолноеИмя);
					сч = сч - 1;
					Если сч = 0 Тогда
						мСписокФайлов.Добавить(СтрШаблон("... и еще %1 файлов", мНайденныеФайлы.Количество() - 10));
						Прервать;
					КонецЕсли;
				КонецЦикла;
				ВызватьИсключение СтрШаблон("
				|Найдено несколько путей для Объкта %1
				|Учточните маску поиска
				| - %2", ОбъектПоиска, СтрСоединить(мСписокФайлов, Символы.ПС + "
				| - "));
			КонецЕсли;

			Если ПозПервогоСлеша = 0 Тогда

				мИменаФайлов = Новый Массив();

				Для каждого Файл Из мНайденныеФайлы Цикл
					Если Файл.ЭтоФайл() Тогда
						мИменаФайлов.Добавить(Файл.ПолноеИмя);
					ИначеЕсли Файл.ЭтоКаталог() Тогда
						мФайлыОбъекта = НайтиФайлы(Файл.ПолноеИмя, ПолучитьМаскуВсеФайлы(), Истина);
						Для Каждого ФайлКаталога Из мФайлыОбъекта Цикл
							Если ФайлКаталога.ЭтоФайл() Тогда
								мИменаФайлов.Добавить(ФайлКаталога.ПолноеИмя);
							КонецЕсли;
						КонецЦикла;
					КонецЕсли;
				КонецЦикла;

				Если мИменаФайлов.Количество() = 0 Тогда
					ВызватьИсключение СтрШаблон("Папка Объекта %1 не содержит файлов", Объект);
				КонецЕсли;
				Для каждого ИмяФайла Из мИменаФайлов Цикл
					мСписокФайлов.Добавить(ИмяФайла);
				КонецЦикла;

				Прервать;
			
			Иначе

				КаталогПоиска = мНайденныеФайлы[0].ПолноеИмя;
				ПозПервогоСлеша = СтрНайти(ХвостОбъекта, "/");
				Если ПозПервогоСлеша = 0 Тогда
					ОбъектПоиска = ХвостОбъекта;
					ХвостОбъекта = "";
				Иначе
					ОбъектПоиска = Лев(ХвостОбъекта, ПозПервогоСлеша - 1);
					ХвостОбъекта = Сред(ХвостОбъекта, ПозПервогоСлеша + 1);
				КонецЕсли;
		
			КонецЕсли;
		
		КонецЦикла;

	КонецЦикла;
	
	мСписокФайлов = НормализоватьИмена(ДополнитьПутиГит(мСписокФайлов));
	
	Возврат ЗаписатьОбъектыВФайл(мСписокФайлов);
	
КонецФункции

Функция СкорректироватьПутьКИзменениюФормы(СтрокаИзмененныхФайлов)

	Паттерны = Новый Массив;
	Паттерны.Добавить("(.*\\Forms\\.*)\\Ext.*");
	Паттерны.Добавить("(.*\\Help)\\.+\.html");

	Для каждого Паттерн Из Паттерны Цикл
		РегулярноеВыражение = Новый РегулярноеВыражение(Паттерн);
		КоллекцияСовпаденийРегулярногоВыражения = РегулярноеВыражение.НайтиСовпадения(СтрокаИзмененныхФайлов);
		Если КоллекцияСовпаденийРегулярногоВыражения.Количество() = 1
			И КоллекцияСовпаденийРегулярногоВыражения[0].Группы.Количество() = 2 Тогда
			ИзмененнаяСтрока = РегулярноеВыражение.Заменить(СтрокаИзмененныхФайлов, "$1.xml");
			Возврат ИзмененнаяСтрока;
		КонецЕсли;
	КонецЦикла;

	Возврат СтрокаИзмененныхФайлов;
КонецФункции

Функция НормализоватьИмена(МассивПутей)
	сИмена = Новый Соответствие();
	Для Каждого Стр Из МассивПутей Цикл
		Стр = СокрЛП(Стр);
		Стр = СкорректироватьПутьКИзменениюФормы(Стр);
		сИмена.Вставить(Стр);
	КонецЦикла;
	мТекст = Новый Массив();
	Для каждого КЗ Из сИмена Цикл
		мТекст.Добавить(КЗ.Ключ);
	КонецЦикла;
	Возврат мТекст;
КонецФункции

Функция ЗаписатьОбъектыВФайл(мОбъекты)
	
	Текст = СтрСоединить(мОбъекты, Символы.ПС);

	Если ПустаяСтрока(Текст) Тогда
		Возврат "";
	КонецЕсли;
	
	ИмяФайла = ИмяФайлаСпискаОбъектовПоУмолчанию();

	Служебные.ЗаписатьВФайл(ИмяФайла, Текст);
	
	Возврат ИмяФайла;

КонецФункции

Функция ИмяФайлаСпискаОбъектовПоУмолчанию() Экспорт
	Каталог = ОбъединитьПути(Путь, "temp");
	ФС.ОбеспечитьКаталог(Каталог);
	Возврат ОбъединитьПути(Каталог, "СписокОбъектовДляЗагрузки.txt");
КонецФункции

Функция ВыполнитьКоманду(Строка)
	Возврат Служебные.ВыполнитьКоманду(Строка, Путь, "Строка");
КонецФункции

Функция ВыполнитьКомандуВМассив(Строка)
	Возврат Служебные.ВыполнитьКоманду(Строка, Путь, "Массив");
КонецФункции

Функция ВыполнитьГитКоманду(КоманднаяСтрока, ДопустимыйКодВозврата = 0) Экспорт

	Лог.Информация(" > " + КоманднаяСтрока);

	мЧасти = СтрРазделить(КоманднаяСтрока, " ", Ложь);
	Если НРег(мЧасти[0]) = "git" Тогда
		мЧасти.Удалить(0);
	КонецЕсли;

	ГитРепозиторий.ВыполнитьКоманду(мЧасти, ДопустимыйКодВозврата);

	ВыводКоманды = ГитРепозиторий.ПолучитьВыводКоманды();
	
	Если РежимВыводаСообщений Тогда
		Сообщить(ВыводКоманды);
	КонецЕсли;

	Возврат ВыводКоманды;

КонецФункции

Процедура УстановитьРежимВыводаСообщений(Режим) Экспорт
	РежимВыводаСообщений = Режим;
КонецПроцедуры