using System;
using System.Collections.Generic;

namespace SQLAPI
{
    public class SQLResult
    {
        public bool Result {get; set;}

        public List<string> Data {get; set;}

        public string ErrorMessage {get; set;}
    }
}
