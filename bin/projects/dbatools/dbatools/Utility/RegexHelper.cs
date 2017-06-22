﻿namespace Sqlcollaborative.Dbatools
{
    namespace Utility
    {
        /// <summary>
        /// Static class that holds useful regex patterns, ready for use
        /// </summary>
        public static class RegexHelper
        {
            /// <summary>
            /// Pattern that checks for a valid hostname
            /// </summary>
            public static string HostName = @"^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]))*$";

            /// <summary>
            /// Pattern that checks for valid hostnames within a larger text
            /// </summary>
            public static string HostNameEx = @"([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]))*";

            /// <summary>
            /// Pattern that checks for a valid IPv4 address
            /// </summary>
            public static string IPv4 = @"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$";

            /// <summary>
            /// Pattern that checks for valid IPv4 addresses within a larger text
            /// </summary>
            public static string IPv4Ex = @"(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}";

            /// <summary>
            /// Will match a valid IPv6 address
            /// </summary>
            public static string IPv6 = @"^(?:^|(?<=\s))(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))(?=\s|$)$";

            /// <summary>
            /// Will match any IPv6 address within a larger text
            /// </summary>
            public static string IPv6Ex = @"(?:^|(?<=\s))(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))(?=\s|$)";

            /// <summary>
            /// Will match any string that in its entirety represents a valid target for dns- or ip-based targeting. Combination of HostName, IPv4 and IPv6
            /// </summary>
            public static string ComputerTarget = @"^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]))*$|^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$|^(?:^|(?<=\s))(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))(?=\s|$)$";

            /// <summary>
            /// Will match a valid Guid
            /// </summary>
            public static string Guid = @"^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$";

            /// <summary>
            /// Will match any number of valid Guids in a larger text
            /// </summary>
            public static string GuidEx = @"(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})";

            /// <summary>
            /// Will match a mostly valid instance name.
            /// </summary>
            public static string InstanceName = @"^[\p{L}&_#][\p{L}\d\$#_]{1,15}$";

            /// <summary>
            /// Will match any instance of a mostly valid instance name.
            /// </summary>
            public static string InstanceNameEx = @"[\p{L}&_#][\p{L}\d\$#_]{1,15}";

            /// <summary>
            /// Matches a word against the list of officially reserved keywords
            /// </summary>
            public static string SqlReservedKeyword = @"^ADD$|^ALL$|^ALTER$|^AND$|^ANY$|^AS$|^ASC$|^AUTHORIZATION$|^BACKUP$|^BEGIN$|^BETWEEN$|^BREAK$|^BROWSE$|^BULK$|^BY$|^CASCADE$|^CASE$|^CHECK$|^CHECKPOINT$|^CLOSE$|^CLUSTERED$|^COALESCE$|^COLLATE$|^COLUMN$|^COMMIT$|^COMPUTE$|^CONSTRAINT$|^CONTAINS$|^CONTAINSTABLE$|^CONTINUE$|^CONVERT$|^CREATE$|^CROSS$|^CURRENT$|^CURRENT_DATE$|^CURRENT_TIME$|^CURRENT_TIMESTAMP$|^CURRENT_USER$|^CURSOR$|^DATABASE$|^DBCC$|^DEALLOCATE$|^DECLARE$|^DEFAULT$|^DELETE$|^DENY$|^DESC$|^DISK$|^DISTINCT$|^DISTRIBUTED$|^DOUBLE$|^DROP$|^DUMP$|^ELSE$|^END$|^ERRLVL$|^ESCAPE$|^EXCEPT$|^EXEC$|^EXECUTE$|^EXISTS$|^EXIT$|^EXTERNAL$|^FETCH$|^FILE$|^FILLFACTOR$|^FOR$|^FOREIGN$|^FREETEXT$|^FREETEXTTABLE$|^FROM$|^FULL$|^FUNCTION$|^GOTO$|^GRANT$|^GROUP$|^HAVING$|^HOLDLOCK$|^IDENTITY$|^IDENTITY_INSERT$|^IDENTITYCOL$|^IF$|^IN$|^INDEX$|^INNER$|^INSERT$|^INTERSECT$|^INTO$|^IS$|^JOIN$|^KEY$|^KILL$|^LEFT$|^LIKE$|^LINENO$|^LOAD$|^MERGE$|^NATIONAL$|^NOCHECK$|^NONCLUSTERED$|^NOT$|^NULL$|^NULLIF$|^OF$|^OFF$|^OFFSETS$|^ON$|^OPEN$|^OPENDATASOURCE$|^OPENQUERY$|^OPENROWSET$|^OPENXML$|^OPTION$|^OR$|^ORDER$|^OUTER$|^OVER$|^PERCENT$|^PIVOT$|^PLAN$|^PRECISION$|^PRIMARY$|^PRINT$|^PROC$|^PROCEDURE$|^PUBLIC$|^RAISERROR$|^READ$|^READTEXT$|^RECONFIGURE$|^REFERENCES$|^REPLICATION$|^RESTORE$|^RESTRICT$|^RETURN$|^REVERT$|^REVOKE$|^RIGHT$|^ROLLBACK$|^ROWCOUNT$|^ROWGUIDCOL$|^RULE$|^SAVE$|^SCHEMA$|^SECURITYAUDIT$|^SELECT$|^SEMANTICKEYPHRASETABLE$|^SEMANTICSIMILARITYDETAILSTABLE$|^SEMANTICSIMILARITYTABLE$|^SESSION_USER$|^SET$|^SETUSER$|^SHUTDOWN$|^SOME$|^STATISTICS$|^SYSTEM_USER$|^TABLE$|^TABLESAMPLE$|^TEXTSIZE$|^THEN$|^TO$|^TOP$|^TRAN$|^TRANSACTION$|^TRIGGER$|^TRUNCATE$|^TRY_CONVERT$|^TSEQUAL$|^UNION$|^UNIQUE$|^UNPIVOT$|^UPDATE$|^UPDATETEXT$|^USE$|^USER$|^VALUES$|^VARYING$|^VIEW$|^WAITFOR$|^WHEN$|^WHERE$|^WHILE$|^WITH$|^WITHIN GROUP$|^WRITETEXT$";

            /// <summary>
            /// Will match any reserved keyword in a larger text
            /// </summary>
            public static string SqlReservedKeywordEx = @"ADD|ALL|ALTER|AND|ANY|AS|ASC|AUTHORIZATION|BACKUP|BEGIN|BETWEEN|BREAK|BROWSE|BULK|BY|CASCADE|CASE|CHECK|CHECKPOINT|CLOSE|CLUSTERED|COALESCE|COLLATE|COLUMN|COMMIT|COMPUTE|CONSTRAINT|CONTAINS|CONTAINSTABLE|CONTINUE|CONVERT|CREATE|CROSS|CURRENT|CURRENT_DATE|CURRENT_TIME|CURRENT_TIMESTAMP|CURRENT_USER|CURSOR|DATABASE|DBCC|DEALLOCATE|DECLARE|DEFAULT|DELETE|DENY|DESC|DISK|DISTINCT|DISTRIBUTED|DOUBLE|DROP|DUMP|ELSE|END|ERRLVL|ESCAPE|EXCEPT|EXEC|EXECUTE|EXISTS|EXIT|EXTERNAL|FETCH|FILE|FILLFACTOR|FOR|FOREIGN|FREETEXT|FREETEXTTABLE|FROM|FULL|FUNCTION|GOTO|GRANT|GROUP|HAVING|HOLDLOCK|IDENTITY|IDENTITY_INSERT|IDENTITYCOL|IF|IN|INDEX|INNER|INSERT|INTERSECT|INTO|IS|JOIN|KEY|KILL|LEFT|LIKE|LINENO|LOAD|MERGE|NATIONAL|NOCHECK|NONCLUSTERED|NOT|NULL|NULLIF|OF|OFF|OFFSETS|ON|OPEN|OPENDATASOURCE|OPENQUERY|OPENROWSET|OPENXML|OPTION|OR|ORDER|OUTER|OVER|PERCENT|PIVOT|PLAN|PRECISION|PRIMARY|PRINT|PROC|PROCEDURE|PUBLIC|RAISERROR|READ|READTEXT|RECONFIGURE|REFERENCES|REPLICATION|RESTORE|RESTRICT|RETURN|REVERT|REVOKE|RIGHT|ROLLBACK|ROWCOUNT|ROWGUIDCOL|RULE|SAVE|SCHEMA|SECURITYAUDIT|SELECT|SEMANTICKEYPHRASETABLE|SEMANTICSIMILARITYDETAILSTABLE|SEMANTICSIMILARITYTABLE|SESSION_USER|SET|SETUSER|SHUTDOWN|SOME|STATISTICS|SYSTEM_USER|TABLE|TABLESAMPLE|TEXTSIZE|THEN|TO|TOP|TRAN|TRANSACTION|TRIGGER|TRUNCATE|TRY_CONVERT|TSEQUAL|UNION|UNIQUE|UNPIVOT|UPDATE|UPDATETEXT|USE|USER|VALUES|VARYING|VIEW|WAITFOR|WHEN|WHERE|WHILE|WITH|WITHIN GROUP|WRITETEXT";

            /// <summary>
            /// Matches a word against the list of officially reserved keywords for odbc
            /// </summary>
            public static string SqlReservedKeywordOdbc = @"^ABSOLUTE$|^ACTION$|^ADA$|^ADD$|^ALL$|^ALLOCATE$|^ALTER$|^AND$|^ANY$|^ARE$|^AS$|^ASC$|^ASSERTION$|^AT$|^AUTHORIZATION$|^AVG$|^BEGIN$|^BETWEEN$|^BIT$|^BIT_LENGTH$|^BOTH$|^BY$|^CASCADE$|^CASCADED$|^CASE$|^CAST$|^CATALOG$|^CHAR$|^CHAR_LENGTH$|^CHARACTER$|^CHARACTER_LENGTH$|^CHECK$|^CLOSE$|^COALESCE$|^COLLATE$|^COLLATION$|^COLUMN$|^COMMIT$|^CONNECT$|^CONNECTION$|^CONSTRAINT$|^CONSTRAINTS$|^CONTINUE$|^CONVERT$|^CORRESPONDING$|^COUNT$|^CREATE$|^CROSS$|^CURRENT$|^CURRENT_DATE$|^CURRENT_TIME$|^CURRENT_TIMESTAMP$|^CURRENT_USER$|^CURSOR$|^DATE$|^DAY$|^DEALLOCATE$|^DEC$|^DECIMAL$|^DECLARE$|^DEFAULT$|^DEFERRABLE$|^DEFERRED$|^DELETE$|^DESC$|^DESCRIBE$|^DESCRIPTOR$|^DIAGNOSTICS$|^DISCONNECT$|^DISTINCT$|^DOMAIN$|^DOUBLE$|^DROP$|^ELSE$|^END$|^END-EXEC$|^ESCAPE$|^EXCEPT$|^EXCEPTION$|^EXEC$|^EXECUTE$|^EXISTS$|^EXTERNAL$|^EXTRACT$|^FALSE$|^FETCH$|^FIRST$|^FLOAT$|^FOR$|^FOREIGN$|^FORTRAN$|^FOUND$|^FROM$|^FULL$|^GET$|^GLOBAL$|^GO$|^GOTO$|^GRANT$|^GROUP$|^HAVING$|^HOUR$|^IDENTITY$|^IMMEDIATE$|^IN$|^INCLUDE$|^INDEX$|^INDICATOR$|^INITIALLY$|^INNER$|^INPUT$|^INSENSITIVE$|^INSERT$|^INT$|^INTEGER$|^INTERSECT$|^INTERVAL$|^INTO$|^IS$|^ISOLATION$|^JOIN$|^KEY$|^LANGUAGE$|^LAST$|^LEADING$|^LEFT$|^LEVEL$|^LIKE$|^LOCAL$|^LOWER$|^MATCH$|^MAX$|^MIN$|^MINUTE$|^MODULE$|^MONTH$|^NAMES$|^NATIONAL$|^NATURAL$|^NCHAR$|^NEXT$|^NO$|^NONE$|^NOT$|^NULL$|^NULLIF$|^NUMERIC$|^OCTET_LENGTH$|^OF$|^ON$|^ONLY$|^OPEN$|^OPTION$|^OR$|^ORDER$|^OUTER$|^OUTPUT$|^OVERLAPS$|^PAD$|^PARTIAL$|^PASCAL$|^POSITION$|^PRECISION$|^PREPARE$|^PRESERVE$|^PRIMARY$|^PRIOR$|^PRIVILEGES$|^PROCEDURE$|^PUBLIC$|^READ$|^REAL$|^REFERENCES$|^RELATIVE$|^RESTRICT$|^REVOKE$|^RIGHT$|^ROLLBACK$|^ROWS$|^SCHEMA$|^SCROLL$|^SECOND$|^SECTION$|^SELECT$|^SESSION$|^SESSION_USER$|^SET$|^SIZE$|^SMALLINT$|^SOME$|^SPACE$|^SQL$|^SQLCA$|^SQLCODE$|^SQLERROR$|^SQLSTATE$|^SQLWARNING$|^SUBSTRING$|^SUM$|^SYSTEM_USER$|^TABLE$|^TEMPORARY$|^THEN$|^TIME$|^TIMESTAMP$|^TIMEZONE_HOUR$|^TIMEZONE_MINUTE$|^TO$|^TRAILING$|^TRANSACTION$|^TRANSLATE$|^TRANSLATION$|^TRIM$|^TRUE$|^UNION$|^UNIQUE$|^UNKNOWN$|^UPDATE$|^UPPER$|^USAGE$|^USER$|^USING$|^VALUE$|^VALUES$|^VARCHAR$|^VARYING$|^VIEW$|^WHEN$|^WHENEVER$|^WHERE$|^WITH$|^WORK$|^WRITE$|^YEAR$|^ZONE$";

            /// <summary>
            /// Will match any reserved odbc-keyword in a larger text
            /// </summary>
            public static string SqlReservedKeywordOdbcEx = @"ABSOLUTE|ACTION|ADA|ADD|ALL|ALLOCATE|ALTER|AND|ANY|ARE|AS|ASC|ASSERTION|AT|AUTHORIZATION|AVG|BEGIN|BETWEEN|BIT|BIT_LENGTH|BOTH|BY|CASCADE|CASCADED|CASE|CAST|CATALOG|CHAR|CHAR_LENGTH|CHARACTER|CHARACTER_LENGTH|CHECK|CLOSE|COALESCE|COLLATE|COLLATION|COLUMN|COMMIT|CONNECT|CONNECTION|CONSTRAINT|CONSTRAINTS|CONTINUE|CONVERT|CORRESPONDING|COUNT|CREATE|CROSS|CURRENT|CURRENT_DATE|CURRENT_TIME|CURRENT_TIMESTAMP|CURRENT_USER|CURSOR|DATE|DAY|DEALLOCATE|DEC|DECIMAL|DECLARE|DEFAULT|DEFERRABLE|DEFERRED|DELETE|DESC|DESCRIBE|DESCRIPTOR|DIAGNOSTICS|DISCONNECT|DISTINCT|DOMAIN|DOUBLE|DROP|ELSE|END|END-EXEC|ESCAPE|EXCEPT|EXCEPTION|EXEC|EXECUTE|EXISTS|EXTERNAL|EXTRACT|FALSE|FETCH|FIRST|FLOAT|FOR|FOREIGN|FORTRAN|FOUND|FROM|FULL|GET|GLOBAL|GO|GOTO|GRANT|GROUP|HAVING|HOUR|IDENTITY|IMMEDIATE|IN|INCLUDE|INDEX|INDICATOR|INITIALLY|INNER|INPUT|INSENSITIVE|INSERT|INT|INTEGER|INTERSECT|INTERVAL|INTO|IS|ISOLATION|JOIN|KEY|LANGUAGE|LAST|LEADING|LEFT|LEVEL|LIKE|LOCAL|LOWER|MATCH|MAX|MIN|MINUTE|MODULE|MONTH|NAMES|NATIONAL|NATURAL|NCHAR|NEXT|NO|NONE|NOT|NULL|NULLIF|NUMERIC|OCTET_LENGTH|OF|ON|ONLY|OPEN|OPTION|OR|ORDER|OUTER|OUTPUT|OVERLAPS|PAD|PARTIAL|PASCAL|POSITION|PRECISION|PREPARE|PRESERVE|PRIMARY|PRIOR|PRIVILEGES|PROCEDURE|PUBLIC|READ|REAL|REFERENCES|RELATIVE|RESTRICT|REVOKE|RIGHT|ROLLBACK|ROWS|SCHEMA|SCROLL|SECOND|SECTION|SELECT|SESSION|SESSION_USER|SET|SIZE|SMALLINT|SOME|SPACE|SQL|SQLCA|SQLCODE|SQLERROR|SQLSTATE|SQLWARNING|SUBSTRING|SUM|SYSTEM_USER|TABLE|TEMPORARY|THEN|TIME|TIMESTAMP|TIMEZONE_HOUR|TIMEZONE_MINUTE|TO|TRAILING|TRANSACTION|TRANSLATE|TRANSLATION|TRIM|TRUE|UNION|UNIQUE|UNKNOWN|UPDATE|UPPER|USAGE|USER|USING|VALUE|VALUES|VARCHAR|VARYING|VIEW|WHEN|WHENEVER|WHERE|WITH|WORK|WRITE|YEAR|ZONE";

            /// <summary>
            /// Matches a word against the list of keywords that are likely to become reserved in the future
            /// </summary>
            public static string SqlReservedKeywordFuture = @"^ABSOLUTE$|^ACTION$|^ADMIN$|^AFTER$|^AGGREGATE$|^ALIAS$|^ALLOCATE$|^ARE$|^ARRAY$|^ASENSITIVE$|^ASSERTION$|^ASYMMETRIC$|^AT$|^ATOMIC$|^BEFORE$|^BINARY$|^BIT$|^BLOB$|^BOOLEAN$|^BOTH$|^BREADTH$|^CALL$|^CALLED$|^CARDINALITY$|^CASCADED$|^CAST$|^CATALOG$|^CHAR$|^CHARACTER$|^CLASS$|^CLOB$|^COLLATION$|^COLLECT$|^COMPLETION$|^CONDITION$|^CONNECT$|^CONNECTION$|^CONSTRAINTS$|^CONSTRUCTOR$|^CORR$|^CORRESPONDING$|^COVAR_POP$|^COVAR_SAMP$|^CUBE$|^CUME_DIST$|^CURRENT_CATALOG$|^CURRENT_DEFAULT_TRANSFORM_GROUP$|^CURRENT_PATH$|^CURRENT_ROLE$|^CURRENT_SCHEMA$|^CURRENT_TRANSFORM_GROUP_FOR_TYPE$|^CYCLE$|^DATA$|^DATE$|^DAY$|^DEC$|^DECIMAL$|^DEFERRABLE$|^DEFERRED$|^DEPTH$|^DEREF$|^DESCRIBE$|^DESCRIPTOR$|^DESTROY$|^DESTRUCTOR$|^DETERMINISTIC$|^DIAGNOSTICS$|^DICTIONARY$|^DISCONNECT$|^DOMAIN$|^DYNAMIC$|^EACH$|^ELEMENT$|^END-EXEC$|^EQUALS$|^EVERY$|^EXCEPTION$|^FALSE$|^FILTER$|^FIRST$|^FLOAT$|^FOUND$|^FREE$|^FULLTEXTTABLE$|^FUSION$|^GENERAL$|^GET$|^GLOBAL$|^GO$|^GROUPING$|^HOLD$|^HOST$|^HOUR$|^IGNORE$|^IMMEDIATE$|^INDICATOR$|^INITIALIZE$|^INITIALLY$|^INOUT$|^INPUT$|^INT$|^INTEGER$|^INTERSECTION$|^INTERVAL$|^ISOLATION$|^ITERATE$|^LANGUAGE$|^LARGE$|^LAST$|^LATERAL$|^LEADING$|^LESS$|^LEVEL$|^LIKE_REGEX$|^LIMIT$|^LN$|^LOCAL$|^LOCALTIME$|^LOCALTIMESTAMP$|^LOCATOR$|^MAP$|^MATCH$|^MEMBER$|^METHOD$|^MINUTE$|^MOD$|^MODIFIES$|^MODIFY$|^MODULE$|^MONTH$|^MULTISET$|^NAMES$|^NATURAL$|^NCHAR$|^NCLOB$|^NEW$|^NEXT$|^NO$|^NONE$|^NORMALIZE$|^NUMERIC$|^OBJECT$|^OCCURRENCES_REGEX$|^OLD$|^ONLY$|^OPERATION$|^ORDINALITY$|^OUT$|^OUTPUT$|^OVERLAY$|^PAD$|^PARAMETER$|^PARAMETERS$|^PARTIAL$|^PARTITION$|^PATH$|^PERCENT_RANK$|^PERCENTILE_CONT$|^PERCENTILE_DISC$|^POSITION_REGEX$|^POSTFIX$|^PREFIX$|^PREORDER$|^PREPARE$|^PRESERVE$|^PRIOR$|^PRIVILEGES$|^RANGE$|^READS$|^REAL$|^RECURSIVE$|^REF$|^REFERENCING$|^REGR_AVGX$|^REGR_AVGY$|^REGR_COUNT$|^REGR_INTERCEPT$|^REGR_R2$|^REGR_SLOPE$|^REGR_SXX$|^REGR_SXY$|^REGR_SYY$|^RELATIVE$|^RELEASE$|^RESULT$|^RETURNS$|^ROLE$|^ROLLUP$|^ROUTINE$|^ROW$|^ROWS$|^SAVEPOINT$|^SCOPE$|^SCROLL$|^SEARCH$|^SECOND$|^SECTION$|^SENSITIVE$|^SEQUENCE$|^SESSION$|^SETS$|^SIMILAR$|^SIZE$|^SMALLINT$|^SPACE$|^SPECIFIC$|^SPECIFICTYPE$|^SQL$|^SQLEXCEPTION$|^SQLSTATE$|^SQLWARNING$|^START$|^STATE$|^STATEMENT$|^STATIC$|^STDDEV_POP$|^STDDEV_SAMP$|^STRUCTURE$|^SUBMULTISET$|^SUBSTRING_REGEX$|^SYMMETRIC$|^SYSTEM$|^TEMPORARY$|^TERMINATE$|^THAN$|^TIME$|^TIMESTAMP$|^TIMEZONE_HOUR$|^TIMEZONE_MINUTE$|^TRAILING$|^TRANSLATE_REGEX$|^TRANSLATION$|^TREAT$|^TRUE$|^UESCAPE$|^UNDER$|^UNKNOWN$|^UNNEST$|^USAGE$|^USING$|^VALUE$|^VAR_POP$|^VAR_SAMP$|^VARCHAR$|^VARIABLE$|^WHENEVER$|^WIDTH_BUCKET$|^WINDOW$|^WITHIN$|^WITHOUT$|^WORK$|^WRITE$|^XMLAGG$|^XMLATTRIBUTES$|^XMLBINARY$|^XMLCAST$|^XMLCOMMENT$|^XMLCONCAT$|^XMLDOCUMENT$|^XMLELEMENT$|^XMLEXISTS$|^XMLFOREST$|^XMLITERATE$|^XMLNAMESPACES$|^XMLPARSE$|^XMLPI$|^XMLQUERY$|^XMLSERIALIZE$|^XMLTABLE$|^XMLTEXT$|^XMLVALIDATE$|^YEAR$|^ZONE$";

            /// <summary>
            /// Will match against the list of keywords that are likely to become reserved in the future and are used in a larger text
            /// </summary>
            public static string SqlReservedKeywordFutureEx = @"ABSOLUTE|ACTION|ADMIN|AFTER|AGGREGATE|ALIAS|ALLOCATE|ARE|ARRAY|ASENSITIVE|ASSERTION|ASYMMETRIC|AT|ATOMIC|BEFORE|BINARY|BIT|BLOB|BOOLEAN|BOTH|BREADTH|CALL|CALLED|CARDINALITY|CASCADED|CAST|CATALOG|CHAR|CHARACTER|CLASS|CLOB|COLLATION|COLLECT|COMPLETION|CONDITION|CONNECT|CONNECTION|CONSTRAINTS|CONSTRUCTOR|CORR|CORRESPONDING|COVAR_POP|COVAR_SAMP|CUBE|CUME_DIST|CURRENT_CATALOG|CURRENT_DEFAULT_TRANSFORM_GROUP|CURRENT_PATH|CURRENT_ROLE|CURRENT_SCHEMA|CURRENT_TRANSFORM_GROUP_FOR_TYPE|CYCLE|DATA|DATE|DAY|DEC|DECIMAL|DEFERRABLE|DEFERRED|DEPTH|DEREF|DESCRIBE|DESCRIPTOR|DESTROY|DESTRUCTOR|DETERMINISTIC|DIAGNOSTICS|DICTIONARY|DISCONNECT|DOMAIN|DYNAMIC|EACH|ELEMENT|END-EXEC|EQUALS|EVERY|EXCEPTION|FALSE|FILTER|FIRST|FLOAT|FOUND|FREE|FULLTEXTTABLE|FUSION|GENERAL|GET|GLOBAL|GO|GROUPING|HOLD|HOST|HOUR|IGNORE|IMMEDIATE|INDICATOR|INITIALIZE|INITIALLY|INOUT|INPUT|INT|INTEGER|INTERSECTION|INTERVAL|ISOLATION|ITERATE|LANGUAGE|LARGE|LAST|LATERAL|LEADING|LESS|LEVEL|LIKE_REGEX|LIMIT|LN|LOCAL|LOCALTIME|LOCALTIMESTAMP|LOCATOR|MAP|MATCH|MEMBER|METHOD|MINUTE|MOD|MODIFIES|MODIFY|MODULE|MONTH|MULTISET|NAMES|NATURAL|NCHAR|NCLOB|NEW|NEXT|NO|NONE|NORMALIZE|NUMERIC|OBJECT|OCCURRENCES_REGEX|OLD|ONLY|OPERATION|ORDINALITY|OUT|OUTPUT|OVERLAY|PAD|PARAMETER|PARAMETERS|PARTIAL|PARTITION|PATH|PERCENT_RANK|PERCENTILE_CONT|PERCENTILE_DISC|POSITION_REGEX|POSTFIX|PREFIX|PREORDER|PREPARE|PRESERVE|PRIOR|PRIVILEGES|RANGE|READS|REAL|RECURSIVE|REF|REFERENCING|REGR_AVGX|REGR_AVGY|REGR_COUNT|REGR_INTERCEPT|REGR_R2|REGR_SLOPE|REGR_SXX|REGR_SXY|REGR_SYY|RELATIVE|RELEASE|RESULT|RETURNS|ROLE|ROLLUP|ROUTINE|ROW|ROWS|SAVEPOINT|SCOPE|SCROLL|SEARCH|SECOND|SECTION|SENSITIVE|SEQUENCE|SESSION|SETS|SIMILAR|SIZE|SMALLINT|SPACE|SPECIFIC|SPECIFICTYPE|SQL|SQLEXCEPTION|SQLSTATE|SQLWARNING|START|STATE|STATEMENT|STATIC|STDDEV_POP|STDDEV_SAMP|STRUCTURE|SUBMULTISET|SUBSTRING_REGEX|SYMMETRIC|SYSTEM|TEMPORARY|TERMINATE|THAN|TIME|TIMESTAMP|TIMEZONE_HOUR|TIMEZONE_MINUTE|TRAILING|TRANSLATE_REGEX|TRANSLATION|TREAT|TRUE|UESCAPE|UNDER|UNKNOWN|UNNEST|USAGE|USING|VALUE|VAR_POP|VAR_SAMP|VARCHAR|VARIABLE|WHENEVER|WIDTH_BUCKET|WINDOW|WITHIN|WITHOUT|WORK|WRITE|XMLAGG|XMLATTRIBUTES|XMLBINARY|XMLCAST|XMLCOMMENT|XMLCONCAT|XMLDOCUMENT|XMLELEMENT|XMLEXISTS|XMLFOREST|XMLITERATE|XMLNAMESPACES|XMLPARSE|XMLPI|XMLQUERY|XMLSERIALIZE|XMLTABLE|XMLTEXT|XMLVALIDATE|YEAR|ZONE";
        }
    }
}