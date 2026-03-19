#include <stdio.h>
#include <iostream>
#include <omp.h>

using namespace std;


int main() {
    setlocale(LC_ALL, "RUS");

    int shared_counter = 0;
    int local_modifications = 0;

    cout <<("ДО параллельной области:\n");
    cout <<("shared_counter = %d\n\n", shared_counter);


    //
#pragma omp parallel num_threads(4) shared(shared_counter, local_modifications)
    {
        int thread_id = omp_get_thread_num();
        int local_var = thread_id * 5;  // Локальная переменная для каждого потока

        cout <<("Поток %d: Начальное local_var = %d\n", thread_id, local_var);

    //

        // Основная работа потоков РАБОАТЬ РАБОТАТЬ РАБОТАТЬ
#pragma omp for
        for (int i = 0; i < 10; i++) {
            // Каждый поток выполняет свою часть работы
            // (просто для демонстрации)
        }
        //


        //
        // Блок master - выполняется только главным потоком (thread 0)
#pragma omp master
        {
            cout <<("\n--- MASTER блок (только поток %d) ---\n", omp_get_thread_num());

            // Изменяем локальную переменную ТОЛЬКО в пределах master блока
            local_var = 777;
            local_modifications++;
            shared_counter += 10;

            cout <<("Поток %d: В master блоке local_var = %d\n",
                omp_get_thread_num(), local_var);
            cout <<("--- Конец master блока ---\n\n");
        }
        // Остальные потоки пропускают master блок и продолжают работу
        // Неявная синхронизация: после master нет барьера
        cout <<("Поток %d: После master local_var = %d\n", thread_id, local_var);
        //

#pragma omp barrier

        // Еще один master блок для демонстрации
#pragma omp master
        {
            cout <<("Второй master блок: поток %d изменяет shared_counter на %d\n",
                omp_get_thread_num(), shared_counter);
        }
    }

    cout <<("\nПОСЛЕ параллельной области:\n");
    cout <<("shared_counter = %d (изменен только главным потоком)\n", shared_counter);
    cout <<("local_modifications = %d (количество выполнений master блока)\n", local_modifications);

    return 0;
}