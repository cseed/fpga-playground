
extern void print_int(int);

int sum(int x)
{
  if (x < 2)
    return 1;
  else
    return x + sum(x - 1);
}

int
main()
{
  print_int(sum(4));
}
