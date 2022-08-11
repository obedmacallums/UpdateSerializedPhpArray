IF object_id('fnUpdateSerializedPhpArray') IS NOT NULL
BEGIN
    DROP FUNCTION fnUpdateSerializedPhpArray
END
GO

CREATE FUNCTION fnUpdateSerializedPhpArray (
				@serialized_php_Array VARCHAR(max),
                @key VARCHAR (100),
                @value VARCHAR(MAX)
				)
RETURNS VARCHAR(max)

AS
BEGIN
/*

SPANISH

@serialized_php_Array = Array serializado con la funcion serialize() de php
@key = Nombre de la clave que se desea actualizar o crear
@value = valor de la clave que se desea actualizar o crear

@serialized_php_Array /// DEBE SER UN ARRAY PHP SERIALIZADO VALIDO ///
y es solo para arrays de tipo:

array(
    key1 =>  value1,
    key2 =>  value2,
    key3 =>  value3,
    ...
)

Si la clave (@key) se encuentra dentro del array serializado (@serialized_php_Array)
actualiza el valor de esa clave con un nuevo valor (@value). si esta clave no se encuentra
agrega otro elemento al array serializado (@serialized_php_Array), teniendo como clave @key
y valor @value

Donde @key y @value son solo cadena de texto (NO int, NO Null)
Puede aceptar "" para valores vacios de @value

---------

Dentro de esta funcion se ejecuta otra funcion llamada "fnParsePhpSerializedString"

La funcion "fnParsePhpSerializedString" retorna una tabla de un string serializado con la 
funcion serialize() php con las siguientes columnas:

element_id
parent_id
var_name
var_type
var_length
value_int
value_string
value_decimal

Esta funcion si puede recibir cualquier tipo de objeto serializado
Mas detalles de esta funcion en https://github.com/mttjohnson/tsqlphpunserialize/tree/master

ENGLISH

@serialized_php_Array = Array serialized with the php serialize() function
@key = Name of the key to update or create
@value = value of the key to update or create

@serialized_php_Array /// MUST BE A VALID PHP SERIALIZED ARRAY ///
and it is only for arrays of type:

array(
    key1 => value1,
    key2 => value2,
    key3 => value3,
    ...
)

If the key (@key) is inside the serialized array (@serialized_php_Array)
updates the value of that key with a new value (@value). if this key is not found
adds another element to the serialized array (@serialized_php_Array), having @key as key
and value @value

Where @key and @value are just strings (NOT int, NOT Null)
Can accept "" for empty values ​​of @value

---------

Inside this function another function called "fnParsePhpSerializedString" is executed

The "fnParsePhpSerializedString" function returns a table of a serialized string with the
serialize() php function with the following columns:

element_id
parent_id
var_name
var_type
var_length
value_int
value_string
value_decimal

This function can receive any type of serialized object
More details of this function at https://github.com/mttjohnson/tsqlphpunserialize/tree/master


*/

    DECLARE @table_array as table (
        element_id INT IDENTITY NOT NULL PRIMARY KEY,
        parent_id INT,
        var_name varchar(100), 
        var_type varchar(50),
        var_length int,
        value_string varchar(max)
        )
    
    DECLARE @counter INT
    DECLARE @ELEMENT_ID INT
    DECLARE @VAR_name VARCHAR (100)
    DECLARE @VAR_type VARCHAR(100)
    DECLARE @VAR_length VARCHAR (100)
    DECLARE @VAR_string VARCHAR (100)
    DECLARE @ELEMENT_parent_id INT
    DECLARE @ELEMENT_parsed VARCHAR (100)=''
    DECLARE @ok VARCHAR(max) = ''

        
    INSERT INTO @table_array 
    SELECT parent_id, var_name, var_type, var_length, value_string
    FROM dbo.fnParsePhpSerializedString(@serialized_php_Array)

    
    IF EXISTS (SELECT var_name FROM @table_array WHERE var_name = @key)
        BEGIN
       
        UPDATE @table_array SET 
        value_string = @value,
        var_type = 's',
        var_length = LEN(@value)
        WHERE var_name = @key
        
        END
        
    ELSE
        BEGIN

        INSERT INTO @table_array (parent_id, var_name, var_type, var_length, value_string)
        VALUES(1, @key, 's', LEN(@value), @value)


        UPDATE @table_array SET 
        var_length = var_length + 1
        WHERE parent_id = 0

        END



SELECT @counter = COUNT(*) FROM @table_array

WHILE @counter > 0
        BEGIN
        SET @ELEMENT_parsed = ''
        SET @ELEMENT_parent_id = (SELECT TOP(1) parent_id FROM @table_array)
        SET @ELEMENT_ID = (SELECT TOP(1) element_id FROM @table_array)
        SET @VAR_name = (SELECT TOP(1) var_name FROM @table_array)
        SET @VAR_type = (SELECT TOP(1) var_type FROM @table_array)
        SET @VAR_length = (SELECT TOP(1) var_length FROM @table_array)
        SET @VAR_string = (SELECT TOP(1) value_string FROM @table_array)

        
            IF @ELEMENT_parent_id = 0
                SET @ELEMENT_parsed = CONCAT(@VAR_type, ':', @VAR_length, ':', '{')
            ELSE
            BEGIN

                if @VAR_type='N'
                    SET @ELEMENT_parsed = CONCAT('s', ':', len(@VAR_name),':', '"',@VAR_name,'"', ';', 'N', ';')
                ELSE
                    SET @ELEMENT_parsed = CONCAT(@VAR_type, ':', len(@VAR_name),':', '"',@VAR_name,'"', ';',
                                                @VAR_type,':',len(@VAR_string), ':', '"', @VAR_string,'"', ';')

            END


        SET @ok = @ok + @ELEMENT_parsed

        DELETE TOP (1) FROM @table_array
        SELECT @counter = COUNT(*) FROM @table_array
        END

RETURN @ok + '}'

END