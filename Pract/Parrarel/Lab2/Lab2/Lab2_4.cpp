#include <stdio.h>
#include <iostream>
#include <omp.h>

using namespace std;


int main() {
    setlocale(LC_ALL, "RUS");

    int shared_value = 0;
    int local_value = 100;  // Локальная переменная с начальным значением

    cout <<("ДО параллельной области:\n");
    cout <<("shared_value = %d, local_value = %d\n\n", shared_value, local_value);
    //

        //
#pragma omp parallel num_threads(4) private(local_value) shared(shared_value)
    {
        int thread_id = omp_get_thread_num();

        // Изначально каждый поток имеет свое локальное значение
        local_value = thread_id * 10;  // Каждый поток устанавливает свое значение
        cout <<("Поток %d: Начальное local_value = %d\n", thread_id, local_value);
        //

        //
#pragma omp barrier
        // Барьер для упорядочивания вывода


        //
#pragma omp single copyprivate(local_value)
        {
            // Только один поток выполняет этот блок
            thread_id = omp_get_thread_num();
            cout <<("\n--- Поток %d выполняет single блок с copyprivate ---\n", thread_id);

            // Изменяем локальную переменную в одном потоке
            local_value = 999;
            shared_value = thread_id;  // Запоминаем, какой поток выполнил single

            cout <<("Поток %d установил local_value = %d\n", thread_id, local_value);
        }
        // copyprivate распространяет значение local_value на все потоки
        //

        // Проверка значения после single блока
#pragma omp barrier
        cout <<("Поток %d: После single local_value = %d, shared_value = %d\n",
            omp_get_thread_num(), local_value, shared_value);
    }
        //
    cout <<("\nПОСЛЕ параллельной области:\n");
    cout <<("shared_value = %d (поток %d выполнил single блок)\n", shared_value, shared_value);

    return 0;
}