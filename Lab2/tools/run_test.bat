::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
:: Daca comentam urmatoarea linie de cod, nu se va mai deschide interfata grafica:
vsim -gui -do run.do

::Daca rulam urmatoarea linie de cod, programul se va executa in consola:
:: vsim -c -do run.do
