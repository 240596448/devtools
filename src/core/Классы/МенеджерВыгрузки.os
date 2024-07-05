#Использовать v8runner
#Использовать fs
#Использовать strings

Перем Параметры;

Процедура ПриСозданииОбъекта(пПараметры)
	
	Параметры = Новый Настройки(пПараметры);

КонецПроцедуры

Процедура Выгрузить() Экспорт
	
	Лог = ПараметрыПриложения.Лог();

	КаталогИсходников = Параметры.Репозиторий.ПутьКИсходникам;

	Конфигуратор = Новый Конфигуратор(Параметры);

	ТекущийКаталог = ТекущийКаталог();
	ПапкаЛогов = ОбъединитьПути(ТекущийКаталог, "temp", "logs");
	ФС.ОбеспечитьКаталог(ПапкаЛогов);
	ПутьКФайлуЛогаПлатформы = ОбъединитьПути(ПапкаЛогов, "Выгрузка_" + Параметры.ИмяНастройки + ".log");
	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ПутьКФайлуЛогаПлатформы);

	Лог.Отладка("Путь к файлу лога платформы: %1", ПутьКФайлуЛогаПлатформы);

	Конфигуратор.ВыгрузитьКонфигурациюВФайлы(КаталогИсходников);

	Служебные.ЗаписатьХэшПоследнегоЗагруженногоКоммита(Параметры.Репозиторий.ХэшТекущейВетки());

КонецПроцедуры