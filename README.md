# TSQL SQL SERVER FUNCTION: fnUpdateSerializedPhpArray

This function allows to update a value or create a new key - value to a field of a table that stores serialized values with the php serialize() function,
for more details http://php.fnlist.com/php/serialize


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


