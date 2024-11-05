import os

def test_example():
    assert os.getenv('TEST') == 'OK', "TEST variable should be OK"

if __name__ == '__main__':
    test = os.getenv('TEST')

    if test == 'OK':
        print("All tests passed!")

    if test == 'FAILED':
        print('this line does not work!')
