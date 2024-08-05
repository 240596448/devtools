#Использовать logos

Перем Логгер;
Перем Настройки;

Функция ИмяПриложения() Экспорт
	Возврат "devtools";
КонецФункции

Функция ВерсияПриложения() Экспорт
	Возврат "0.5.0";
КонецФункции

Функция ИмяЛогаПриложения() Экспорт
	Возврат "os.app.dt";
КонецФункции

Функция Лог() Экспорт
	Если Логгер = Неопределено Тогда
		Логгер = Логирование.ПолучитьЛог(ИмяЛогаПриложения());
	КонецЕсли;
	Возврат Логгер;
КонецФункции

Процедура УстановитьНастройки(ПутьКФайлу) Экспорт
	Настройки = Новый Настройки(ПутьКФайлу);
КонецПроцедуры

Функция ПолучитьНастройки() Экспорт
	Настройки.Прочитать();
	Возврат Настройки;
КонецФункции

