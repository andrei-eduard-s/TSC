::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
:: Daca comentam urmatoarea linie de cod, nu se va mai deschide interfata grafica:
::vsim -gui -do run.do


:: Parametrizam scriptul:
:: echo %1 %2 %3 %4 %5 %6 - Afisam parametrii ; %6 - modul gui sau c
:: vsim -gui -do "do run.do %1 %2 %3 %4 %5 %6" 
vsim -gui -do "do run.do %1 %2 %3 %4 %5" 

::Daca rulam urmatoarea linie de cod, programul se va executa in consola:
:: vsim -c -do run.do
