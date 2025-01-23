
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Database Table Info</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f4f4f4;
        }
        .container {
            display: flex;
            max-width: 1300px;
            margin: auto;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .left, .right {
            padding: 20px;
        }
        .left {
            border-right: 1px solid #ddd;
            max-width: 200px;
        }
        .right {
            max-width: 100%;
        }
        h2, h3 {
            margin-top: 0;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            background: #e9ecef;
            margin-bottom: 5px;
            padding: 10px;
            border-radius: 4px;
            cursor: pointer;
        }
        li:hover {
            background: #d4d9dd;
        }
        form input[type="text"] {
            width: 70%;
            padding: 10px;
            margin-right: 10px;
            border-radius: 4px;
            border: 1px solid #ccc;
        }
        form input[type="submit"] {
            padding: 10px 15px;
            border: none;
            background: #28a745;
            color: #fff;
            border-radius: 4px;
            cursor: pointer;
        }
        form input[type="submit"]:hover {
            background: #218838;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
    </style>
    <script>
        function selectTable(tableName) {
            document.getElementById('tableNameInput').value = tableName;
            document.getElementById('tableForm').submit();
        }
    </script>
</head>

<cfoutput>
<body>
    <div class="container">
        <div class="left">
            <h3>Available Tables:</h3>
            <cfquery name="qs_tables" datasource="#cookie.cooksqlfilename#_active">
                SELECT table_name
                FROM information_schema.tables
                WHERE table_type = 'BASE TABLE' 
                  AND table_schema = current_schema()
                ORDER BY table_name
            </cfquery>
            <ul>
                <cfoutput query="qs_tables">
                    <li onclick="selectTable('#table_name#')">#table_name#</li>
                </cfoutput>
            </ul>
        </div>

        <div class="right">
            <cfif structKeyExists(form, "tableName")>
                <h2>Check Database Table Information for "#htmlEditFormat(trim(form.tableName))#"</h2>
            <cfelse>
                <h2>Check Database Table Information</h2>
            </cfif>
            <form method="post" id="tableForm">
                <input type="text" id="tableNameInput" name="tableName" placeholder="Enter table name" required value="">
                <input type="submit" value="Check">
            </form>
            
            <div class="result">
                <cfif structKeyExists(form, "tableName")>
                    <cfset table = trim(form.tableName)>
                    <cfquery name="qs_temp_check_database_table_type_length" datasource="#cookie.cooksqlfilename#_active">
                        SELECT ordinal_position, column_default, is_nullable, character_octet_length, numeric_precision_radix, datetime_precision, 
                        column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
                        FROM information_schema.columns
                        WHERE table_name = <cfqueryparam value="#table#" cfsqltype="cf_sql_varchar">
                          AND table_schema = current_schema()
                    </cfquery>
                    <cfif qs_temp_check_database_table_type_length.RecordCount>
                        <table>
                            <tr>
                                <th>Column Name</th>
                                <th>Data Type</th>
                                <th>Max Length</th>
                            </tr>
                            <cfloop query="qs_temp_check_database_table_type_length">
                                <tr>
                                    <td>#column_name#</td>
                                    <td>#data_type#</td>
                                    <td>
                                    	<cfif character_maximum_length NEQ "">
                                    	#TRIM(character_maximum_length)#
                                    	<cfelseif numeric_precision NEQ "">
                                    		#TRIM(numeric_precision)#
                                    		<cfif numeric_scale NEQ "">
                                    			<br>Decimal: #numeric_scale#
                                    		</cfif>
                                    	</cfif>
                                    </td>
                                </tr>
                            </cfloop>
                        </table>
                    <cfelse>
                        <p>No information found for table "#htmlEditFormat(table)#".</p>
                    </cfif>
                </cfif>
            </div>
        </div>
    </div>
</body>
</cfoutput>
</html>