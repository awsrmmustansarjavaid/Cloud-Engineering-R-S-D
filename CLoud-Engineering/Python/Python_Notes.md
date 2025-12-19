# Python Foundation for AI & ML

> **Author:** Charlie


# Python Foundation for AI & ML

## 1. Introduction to Python
Python is a high-level, interpreted programming language known for its simplicity and extensive libraries. It is the most used language in AI/ML because it provides ready-made libraries that help machines learn from data.

### Why Python is Popular:
* **Simple Syntax:** English-like and easy to read.
* **Huge Libraries:** Reduces the need to write code from scratch.
* **Beginner Friendly:** Saves time and reduces complexity.

### Python in the AI Pipeline:
* **Data Handling:** `NumPy` (numerical calculations) and `Pandas` (data cleaning).
* **Machine Learning:** `Scikit-Learn` (Regression, Classification, Clustering).
* **Deep Learning:** `TensorFlow`, `PyTorch`, `Keras` (Neural Networks).
* **Data Visualization:** `Matplotlib`, `Seaborn` (identifying trends).
* **NLP:** `NLTK`, `SpaCy`, `Transformers` (Chatbots, Sentiment analysis).

---

## 2. Variables & Data Types
A **variable** is a named memory location used to store data values (a container for data).

### Rules for Naming:
* Must start with a letter or underscore.
* Cannot start with a number.
* No spaces allowed; Case-sensitive (`age` != `Age`).

### Common Data Types:
1. **Integer (int):** Whole numbers (e.g., `age = 21`).
2. **Float (float):** Decimal numbers (e.g., `price = 99.99`).
3. **String (str):** Text data in quotes (e.g., `name = "Anees"`).
4. **Boolean (bool):** `True` or `False`. Used for decision making.

**Dynamic Typing:** Python allows changing data types easily (e.g., `x = 10` can later become `x = "hello"`).

---

## 3. Data Collections

| Feature | List `[]` | Tuple `()` | Set `{}` | Dictionary `{K:V}` |
| :--- | :--- | :--- | :--- | :--- |
| **Ordered** | Yes | Yes | No | Yes |
| **Changeable** | Yes (Mutable) | No (Immutable) | Yes | Yes |
| **Duplicates** | Yes | Yes | No | No (Keys) |

* **Lists:** Used for datasets and feature values.
* **Tuples:** Used when data should not change (e.g., coordinates).
* **Sets:** Used to remove duplicate values.
* **Dictionaries:** Used for JSON data, APIs, and ML configurations.

---

## 4. Control Flow & Logic

### Input/Output:
* `input()`: Takes data from users (always as a string). Use `int()` or `float()` to convert.
* `print()`: Displays data to the console.

### Conditions (`if`, `elif`, `else`):
Used to make decisions, check accuracy, or filter data.
```python
marks = 75
if marks >= 80:
    print("Grade A")
elif marks >= 60:
    print("Grade B")
else:
    print("Fail")
```
### Loops:

#### For Loop: 

- **Used when the number of iterations is known (e.g., for i in range(5):).**

#### While Loop: 

- **Runs as long as a condition is true.**

## 5. Functions

A function is a block of reusable code.

### Simple Function:

```
def greet():
    print("Hello AI Intern")
```

With Parameters & Logic:

```
def calculate_accuracy(correct, total):
    return (correct / total) * 100
```

Notes compiled from AI/ML Python Basics Study Sheets.
