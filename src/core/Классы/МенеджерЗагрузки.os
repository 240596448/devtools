#Использовать fs

Перем Параметры;
Перем ИмяФайлаСпискаОбъектов;
Перем ЧастичнаяЗагрузка;
Перем НастройкаПоддержкиИзменена;
Перем СоздатьМеткуПоследнейЗагрузки;

Перем КаталогИсходников;

Перем Лог;
Перем Репозиторий;

Процедура ПриСозданииОбъекта()
	
	Лог = ПараметрыПриложения.Лог();
	Параметры = ПараметрыПриложения.ПолучитьНастройки();

	ИмяФайлаСпискаОбъектов = "";
	ЧастичнаяЗагрузка = Истина;
	НастройкаПоддержкиИзменена = Ложь;
	СоздатьМеткуПоследнейЗагрузки = Ложь;

	Репозиторий = Параметры.Репозиторий;
	
	КаталогИсходников = Репозиторий.ПолныйПутьКИсходникам();

КонецПроцедуры

Процедура Загрузить(ОбъектыКЗагрузке) Экспорт

	ОпределитьТипЗагрузки(ОбъектыКЗагрузке);
	
	Если ПоказатьСписокОбъектовЗагрузки(ИмяФайлаСпискаОбъектов) Тогда
	
		Конфигуратор = Новый Конфигуратор(Параметры);
	
		ПапкаЛогов = ОбъединитьПути(Репозиторий.Путь, "temp", "logs");
		ФС.ОбеспечитьКаталог(ПапкаЛогов);
		ПутьКФайлуЛогаПлатформы = ОбъединитьПути(ПапкаЛогов, "Загрузка_" + Параметры.ИмяНастройки + ".log");
		Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ПутьКФайлуЛогаПлатформы);
		Лог.Отладка("Путь к файлу лога платформы: %1", ПутьКФайлуЛогаПлатформы);
		
		Если НастройкаПоддержкиИзменена Тогда
			ИмяФайлаСОбъектомНастройкиПоддержки = СтрЗаменить(ИмяФайлаСпискаОбъектов, ".", "-0.");
			Служебные.ЗаписатьВФайл(ИмяФайлаСОбъектомНастройкиПоддержки, Репозиторий.ИмяФайлаНастройкиПоддержки());
			Конфигуратор.ЗагрузитьКонфигурациюИзФайлов(КаталогИсходников, ИмяФайлаСОбъектомНастройкиПоддержки);
		КонецЕсли;
	
		Конфигуратор.ЗагрузитьКонфигурациюИзФайлов(КаталогИсходников, ИмяФайлаСпискаОбъектов);
	
	КонецЕсли;
	
	Если СоздатьМеткуПоследнейЗагрузки Тогда
		Репозиторий.ЗаписатьХэшПоследнегоЗагруженногоКоммита();
	КонецЕсли;
	
КонецПроцедуры

Процедура ОпределитьТипЗагрузки(ОбъектыКЗагрузке)

	Если ОбъектыКЗагрузке.Количество() >= 1 Тогда
		
		ВторойАргумент = ОбъектыКЗагрузке[0];
		ТретийАргумент = ?(ОбъектыКЗагрузке.Количество() > 1, ОбъектыКЗагрузке[1], "");

		Если ВторойАргумент = "*" Или ВРег(ВторойАргумент) = "FULL" Тогда
			ЧастичнаяЗагрузка = Ложь;
			СоздатьМеткуПоследнейЗагрузки = Истина;
		ИначеЕсли ВторойАргумент = "+" Тогда
			ИмяФайлаСпискаОбъектов = Репозиторий.ПолучитьСписокИзмененныхФайлов();
			Лог.Информация("Загрузка измененных файлов");
			_Строка = "";
			ВвестиСтроку(_Строка, "Вы можете модифицировать файлы или сбросить изменения... (press ENTER)", 1, Ложь);
		ИначеЕсли ФС.ФайлСуществует(ВторойАргумент) Тогда
			// указываем путь к файлу со списком объектов
			ИмяФайлаСпискаОбъектов = ВторойАргумент;
			Лог.Информация("Загрузка по списку из файла: " + ИмяФайлаСпискаОбъектов);
		ИначеЕсли НРег(ВторойАргумент) = "л" Или НРег(ВторойАргумент) = "l" Тогда
			// указываем путь к файлу со списком объектов
			ИмяФайлаСпискаОбъектов = Репозиторий.ИмяФайлаСпискаОбъектовПоУмолчанию();
			Лог.Информация("Загрузка по списку из стандартного файла: " + ИмяФайлаСпискаОбъектов);
		ИначеЕсли Служебные.ЭтоЧисло(ВторойАргумент) Тогда
			// указываем числами смещения коммитов HEAD~n 
			// если второе число (третий аргумент) не указано - то сравнение с WorkTree
			ИмяФайлаСпискаОбъектов = Репозиторий.ПолучитьСписокПоКоличествуКоммитов(ВторойАргумент, ТретийАргумент);
			Лог.Информация("Загрузка последних " + ВторойАргумент + " коммитов");
		ИначеЕсли ЗначениеЗаполнено(ВторойАргумент)
			И (Служебные.ЭтоВетка(ВторойАргумент) 
				Или Служебные.ЭтоТэг(ВторойАргумент)
				Или Служебные.ЭтоХэшКоммита(ВторойАргумент))
			Тогда
			// указываем ссылки на коммиты (ветки, теги, хэши)
			// если вторая ссылка(третий аргумент) не указана - то сравнение с WorkTree
			ИмяФайлаСпискаОбъектов = Репозиторий.ПолучитьСписокДоКоммита(ВторойАргумент, ТретийАргумент);
			Лог.Информация("Загрузка от метки `" + ВторойАргумент + "` до WorkTree");
		Иначе

			// поиск объектов по маскам (можно указывать несколько объектов)
			мОбъекты = Новый Массив();
			Для инд = 0 По ОбъектыКЗагрузке.Количество() - 1 Цикл
				Объект = ОбъектыКЗагрузке[инд];
				Если ЗначениеЗаполнено(Объект) Тогда
					мОбъекты.Добавить(Объект);
				КонецЕсли;
			КонецЦикла;
			Если ЗначениеЗаполнено(мОбъекты) Тогда
				Лог.Информация("объекты к загрузке:
				| - " + СтрСоединить(мОбъекты, "
				| - "));
				ИмяФайлаСпискаОбъектов = Репозиторий.СформироватьСписок(мОбъекты);
			КонецЕсли;
		КонецЕсли;

	Иначе

		ИмяФайлаСпискаОбъектов = Репозиторий.ПолучитьИзмененныеФайлы();
		СоздатьМеткуПоследнейЗагрузки = Истина;
		Хэш = Репозиторий.ПолучитьХэшПоследнегоЗагруженногоКоммита();
		Если ЗначениеЗаполнено(Хэш) Тогда
			ЧастичнаяЗагрузка = Истина;
			Лог.Информация("Загрузка от последней успешной загрузки (коммит %1) до WorkTree", Хэш);
		Иначе
			ЧастичнаяЗагрузка = ЗначениеЗаполнено(ИмяФайлаСпискаОбъектов);
		КонецЕсли;
			
	КонецЕсли;

КонецПроцедуры

Функция ПоказатьСписокОбъектовЗагрузки(ИмяФайлаСпискаОбъектов)
	
	Если ЧастичнаяЗагрузка = Ложь Тогда
		Лог.Информация("Полная загрузка");
		Возврат Истина;
	ИначеЕсли ПустаяСтрока(ИмяФайлаСпискаОбъектов) Тогда
		Лог.Информация("Нечего загружать");
		Возврат Ложь;
	ИначеЕсли НЕ ФС.ФайлСуществует(ИмяФайлаСпискаОбъектов) Тогда
		ВызватьИсключение "Файл со списком объектов не найден: " + ИмяФайлаСпискаОбъектов;
	КонецЕсли;

	Лог.Информация("загружаемые объекты:");

	мТекст = Служебные.ПрочитатьИзФайла(ИмяФайлаСпискаОбъектов, Истина);
	
	мМассивФайловБезУдаленных = Новый Массив();
	ЕстьУдаление = Ложь;
	Для каждого Стр Из мТекст Цикл
		Если ФС.ФайлСуществует(ОбъединитьПути(КаталогИсходников, Стр)) Тогда
			Лог.Информация(" " + Стр);
			Если Стр = Репозиторий.ИмяФайлаНастройкиПоддержки() Тогда
				НастройкаПоддержкиИзменена = Истина;
			Иначе
				мМассивФайловБезУдаленных.Добавить(Стр);
			КонецЕсли;
		Иначе
			ПутьККорневомуОбъекту = Лев(Стр, СтрНайти(Стр, ПолучитьРазделительПути(), , , 2) - 1) + Сред(Стр, СтрНайти(Стр, ".", НаправлениеПоиска.СКонца));
			Лог.Информация(" " + Стр + " - УДАЛЕН");
			Лог.Информация(" > будет загружен родительский объект целиком " + ПутьККорневомуОбъекту);
			Если мМассивФайловБезУдаленных.Найти(ПутьККорневомуОбъекту) = Неопределено Тогда
				мМассивФайловБезУдаленных.Добавить(ПутьККорневомуОбъекту);
			КонецЕсли;
			ЕстьУдаление = Истина;
		КонецЕсли
	КонецЦикла;

	Если ЕстьУдаление Тогда
		Служебные.ЗаписатьВФайл(ИмяФайлаСпискаОбъектов, СтрСоединить(мМассивФайловБезУдаленных, Символы.ПС));
	КонецЕсли;

	Возврат Истина;

КонецФункции

