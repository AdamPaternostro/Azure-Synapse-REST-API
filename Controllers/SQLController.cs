using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

using Newtonsoft.Json;
using System.Data.SqlClient;
using  Microsoft.Extensions.Configuration;

namespace SQLAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SQLController : ControllerBase
    {


        private readonly ILogger<SQLController> _logger;
        private readonly IConfiguration Configuration;

        public SQLController(ILogger<SQLController> logger, IConfiguration configuration)
        {
            _logger = logger;
             Configuration = configuration;
        }


        [HttpGet]
        public SQLResult Query(string json)
        {
            SQLResult sqlResult = new SQLResult();
            try
            {
                dynamic data = JsonConvert.DeserializeObject(json);
                string operation = data.operation;

                _logger.LogInformation("operation:" + operation);
                _logger.LogInformation("json:" + json);

                 var connectionString = Configuration["SQLConnection"];

                using (SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    sqlConnection.Open();
                    var commandText = "[dbo].[SQL_REST_API]";

                    using (SqlCommand sqlCommand = new SqlCommand(commandText, sqlConnection))
                    {
                        sqlCommand.CommandType = System.Data.CommandType.StoredProcedure;

                        SqlParameter sqlParameter = sqlCommand.Parameters.Add("@json", System.Data.SqlDbType.VarChar, -1);
                        sqlParameter.Value = json;

                        // Execute the command and log the # rows affected.
                        if (operation == "select")
                        {
                            string rowData = "";
                            SqlDataReader reader = sqlCommand.ExecuteReader();
                            sqlResult.Data = new List<string>();
                            while (reader.Read())
                            {
                                rowData = "";
                                // _logger.LogInformation("reader.FieldCount: " + reader.FieldCount.ToString());
                                for (int i = 0; i < reader.FieldCount; i++)
                                {
                                    rowData += ("\"" + reader.GetName(i) + "\" : \"" + reader[i].ToString() + "\",");
                                }
                                sqlResult.Data.Add("{" + rowData.Substring(0,rowData.Length - 1) + "}");
                            }
                            _logger.LogInformation("SELECT executed");
                        }
                        else
                        {
                            sqlCommand.ExecuteNonQueryAsync();
                            _logger.LogInformation("INSERT/UPDATE/DELETE executed");
                        }
                    }
                } // sqlConnection


                sqlResult.Result = true;
                return sqlResult;
            }
            catch (Exception ex)
            {
                _logger.LogError("Error: " + ex.ToString());
                sqlResult.Result = false;
                sqlResult.ErrorMessage = ex.ToString();
                return sqlResult;
            } // try


        } // get
    }
}
