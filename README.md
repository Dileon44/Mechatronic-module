# Mechatronic module

## 1. Общие сведения.

### 1) Тема:
Исследование системы «цифровое устройство управления - импульсный усилитель мощности - электродвигатель»
### 2) Задача:
Используя разные методы импульсного управления, необходимо реализовать возможность регулирования скорости (широтно-импульсная модуляция) и направления вращения коллекторного двигателя постоянного тока. Регулирование скорости должно осуществляться с помощью нажимных кнопок. Относительное значение скорости  должно отображаться на семисегментном индикаторе. ШИМ-сигнал должен иметь три типа реализации: фронтальный, центрированный, задний.
### 3) Результат:
В Simulink смоделированы математические модели (блочно- и компонентно-ориентированные подходы), описывающие физику процессов протекания токов в двигателе постоянного тока, включённого по мостовой схеме (использовался пакет "Simscape Electrical"). В cреде "ModelSim" описана и смоделирована логика работы цифрового устройства управления. В среде "Quartus Prime" произведён синтез проекта в Altera Cyclone IV. Была собрана электросхема, включающая в себя устройство управления, усилитель и электродвигатель. С помощью осциллографа были получены результаты, которые проанализированы в среде MATLAB.
### 4) Технологии:
SystemVerilog, MATLAB, ModelSim, Quartus Prime, Simulink (пакет "Simscape Electrical").

## 2. Описание работы.
1. С помощью 3 кнопок (Up, Down, Direction) можно регулировать скорость и направление вращения электродвигателя, также есть 4 кнопна - Reset (сброс скорости в 0).
2. Нажатие кнопки детекрируется и фильтруется от "дребезга" в модуле Filter (Дребезг. Так как частота работы цифрового устройства большая, в данном случае 50 МГц, при одном нажатии устройство может несколько раз сдетектировать изменение скорости. Такого эффекта не  быть, поэтому вводится период, в течении которого должно детектироваться нажатие)
3. Далее сигналы поступают в модуль PulseGenerator. Этот модуль генерирует импульсы определённым образом для каждой кнопки. Он учитывает возможность регулирования скорости как для разового нажатия, так и для удержания кнопки.
4. Импульсы с PulseGenerator поступают в Counter. Он реализует счётчик - значение скорости.
5. Значение скорости поступает параллельно в PWMGenerator и Data2Segments.
6. PWMGenerator - модуль, который реализует работу ШИМ-сигнала (учитывает фронтальный, центрированный и задний режимы работы ШИМ).
7. Data2Segments отображает значение скорости на семисегментных индикаторах (реализует динамическую индикацию).
8. FoemationSignalsOnKeys открывает и закрывает соответствующие ключи (их 4) в мостовой схеме включения коллекторного двигателя. Он учитывает направление вращения, наличие ШИМ-сигнала (PWM) и синхросигнал (Synch).
9. FormationPause формирует паузу при открытии или закрытии определённых ключей. Пауза нужна, чтобы избежать протекания сквозных токов в мостовой смехе.
