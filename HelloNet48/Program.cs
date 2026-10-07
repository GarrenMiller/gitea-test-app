using System;

namespace HelloNet48
{
    internal static class Program
    {
        private static void Main()
        {
            Console.WriteLine("Hello from .NET Framework 4.8!");
            Console.WriteLine("CLR runtime version: {0}", Environment.Version);
            Console.WriteLine("I was pushed via GitHub, synced to Gitea, then built");
        }
    }
}
