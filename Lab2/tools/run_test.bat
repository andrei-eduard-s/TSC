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
vsim -%6 -do "do run.do %1 %2 %3 %4 %5 %6 %7" 

:: Iesim din directorul sim si intram iar in directorul tools
cd ../tools

::Daca rulam urmatoarea linie de cod, programul se va executa in consola:
:: vsim -c -do run.do
