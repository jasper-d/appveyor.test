using FooLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace FooLib.Tests
{
    public class FooTests
    {
        [Fact]
        public void DoSomethingShouldReturnZero() {
            var foo = new Foo();
            var result = foo.DoSomething();

            Assert.Equal(0, result);
        }
    }
}
