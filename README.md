# Материалы по обучению в Нетологии

## Репозиторий содержит дипломный итоговый проект и домашние работы по всем частям курсам

## Тема дипломной работы "Создание ML модели для классификации (MBTI) по типам личности на основе написанного текста"

### Задача:  
Разработать модель классификации на типы личности на основе написанного текста.
Можно ли обучить искусственный интеллект определить по небольшому тексту характер собеседника?

Классы на основе [MBTI](https://www.myersbriggs.org):
* Introversion (I) – Extroversion (E) / Ориентация сознания: экстраверсия (E) или интроверсия (I).
* Intuition (N) – Sensing (S) / Ориентация в ситуациях: опора на материальную информацию (S) или интуицию (N).
* Thinking (T) – Feeling (F) / Принятие решений: логика (T) или эмоции (F).
* Judging (J) – Perceiving (P) / Подготовка решений: четкое планирование (J) или ориентация на обстоятельства (P).


### Данные:  
Датасет для обучения - [kaggle](https://www.kaggle.com/datasets/datasnaek/mbti-type)  
Я адаптировала классы следующим образом:  
*Аналитик (тип)*  
Стратег — INTJ | Ученый — INTP | Полемист — ENTP | Командир — ENTJ   
*Дипломат (тип)*  
Активист — INFJ | Посредник — INFP | Борец — ENFP | Тренер — ENFJ   
*Хранитель (тип)*  
Администратор — ISTJ | Консул — ESFJ | Защитник — ISFJ | Менеджер — ESTJ   
*Искатель (тип)*  
Виртуоз — ISTP | Артист — ISFP | Делец — ESTP | Развлекатель — ESFP   

Как по типам, так и по классам данные не сбалансированы:  

<img width="933" alt="image" src="https://github.com/lteplova/netology_ds_diplom/assets/38242392/04f68570-dcaf-4ee1-94dc-2d8fdebbb9f6">

<img width="390" alt="image" src="https://github.com/lteplova/netology_ds_diplom/assets/38242392/dba1f5e9-0a25-4029-9837-e2a1e1b57343">

### Мое решение:  

В ходе решения были протестированы несколько различных подходов (обучение проводилось как на 4-х типах, так и на 16 классах):
* Классические модели из библиотеки sklearn:
```RandomForestClassifier(n_estimators=100, random_state = 42)```,  
```LogisticRegression(C = 10, max_iter = 100, class_weight='balanced', random_state = 42)```,  
```SGDClassifier(alpha=0.001, loss='log_loss', tol = 0.0004, epsilon=0.01, max_iter=10, class_weight='balanced', learning_rate = 'optimal', shuffle = False, random_state=42),```  
```SVC(kernel = 'linear', gamma = 'scale', class_weight='balanced', random_state = 42)```,  
```XGBClassifier(n_estimators = 200, max_depth = 2, nthread = 8, learning_rate = 0.2)```  
* Рекуррентная нейройнную сеть ```GRU```
* Трансформер ```Bert```  
Метрики: ```Precision``` и ```Accuracy```

<img width="555" alt="image" src="https://github.com/lteplova/netology_ds_diplom/assets/38242392/e8b7eb28-7fbd-4f5a-879a-6579075c8b07">
<img width="480" alt="image" src="https://github.com/lteplova/netology_ds_diplom/assets/38242392/448d4a5d-0e39-4854-a72e-dba4b77cc645">

Лучший результат получился при обучении Tf-Idf векторов на 4 типа личности, модель SGDClassifier - выбрана в качестве финальной модели

### Используемые технологии:  
```Tf-IDF, W2Vec, nltk, GridSearchCV, sklearn, PyTorch, transformers('bert-base-uncased')```
### Ссылки:  
