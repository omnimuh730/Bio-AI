import ast
import sys
try:
    s = open('detect_food.py', 'r', encoding='utf-8').read()
    ast.parse(s)
    print('PARSE_OK')
except Exception as e:
    print('PARSE_ERR', repr(e))
    sys.exit(1)