# ATTINY2313_FREQMETER

Доработка проекта от - http://www.danyk.cz/avr_fmetr.html

Простой микроконтроллер, работающий на частоте 20 МГц, позволяет измерять частоту до 10 МГц. При этом частотомер автоматически переключает измеряемый диапазон, а соответственно и точность измерения. Всего имеется 4 диапазона, в зависимости от измеряемой частоты.

Диапазон 1 … максимальная частота 9,999 кГц, точность измерения 1 Гц.

Диапазон 2 … максимальная частота 99,99 кГц, точность измерения 10 Гц.

Диапазон 3 … максимальная частота 999,9 кГц, точность измерения 100 Гц.

Диапазон 4 … максимальная частота 9999 кГц, точность измерения 1 кГц.

Текущий диапазон можно определить по положению десятичной точки на индикаторе.


Печатная плата имеет размер 63.5 мм х 38 мм. Как видно на фотографии, большую часть которой занимает индикатор.
Для изготовления методом ЛУТ, имеются изображения печатной платы в чернобелом варианте. Так же к проекту прилагается Gerber-файл.

Собранный частотомер в настройке не нуждается и начинает работать сразу.

Питать частотомер можно не только постоянным напряжением +5 вольт, но и постоянным напряжением от 7 до 12 вольт, для чего на плате устанавливается линейный стабилизатор.

В виду того, что используется микроконтроллер с цифровыми входами, для корректного отображения измеряемой частоты, уровень амплитуды сигнала должен быть около 2.5 вольт.

Для желающих модифицировать исходный код, перевел комментарии автора с чешского на русский язык в файле ATTINY2313_FREQMETER_R.asm .
