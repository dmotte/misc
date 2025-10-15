# eval-md-py

This is an example of how to **evaluate _Python_ code snippets in a _Markdown_ file**, as if they were all part of a single script.

```bash
time bash main.sh README.md; echo $?
```

## Example content

Preliminary steps:

```python
from lib import *

data = nest()
```

Now let's add some data:

```python
data['North America']['Q1']['Laptops'] = 125_000
data['North America']['Q1']['Phones'] = 98_500

data['North America']['Q2']['Laptops'] = 143_200

data['Europe']['Q1']['Laptops'] = 87_300
data['Europe']['Q1']['Phones'] = 65_900

data['Asia']['Q1']['Laptops'] = 192_000
data['Asia']['Q1']['Phones'] = 134_500
```

Finally, let's print the report:

```python
for line in tree_to_lines('TOTAL', data)[0]:
    print(line)
```
