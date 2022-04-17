#include <iostream>
#include <cstring>
using std::cin;
using std::cout;
using std::endl;

extern void FuncStr(const char *s, int a, int b);

void print(char *s)
{
	cout << s << std::endl; 
}

void PrepareStr(char *s)
{
	int len = strlen(s);
	memmove(s + 1, s, len * sizeof(char));
	s[0] = ' ';
	s[len + 1] = ' ';
	s[len + 2] = '\0';
}

int NumberWords(const char *s)
{
	int n = 0, i = 0;
	const char *ptr = s;
	while (ptr[i] != '\0')
	{
		if (ptr[i] == ' ')
		{
			n++;
		}
		i++;
	}
	n++;
	return n; 
}

bool IsError(char *s, int a, int b)
{
		return a > 0 && b > a && b <= NumberWords(s);

}

int main()
{
	int a;
	int b;
	char str[258];
	cout << "Enter string" << endl;
	cin.getline(str, 255, '\n');
	cout << "Enter a, b" << endl;
	cin >> a >> b; 
	if (!IsError(str, a, b))
	{
		puts("Error...");
		return 0;
	}
	cout << str << endl;
	PrepareStr(str);
	FuncStr(str, a, b);
	return 0;
}