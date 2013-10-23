
module.exports = '''

extend_ymd :: false ;
extend_ymd_cmd :: false ;
extend_ymd_format :: false ;

extend_entities :: meta_tag | toc | comment | command | table | extend_ymd ;

meta_tag :: meta#_meta_tag eol+ ;
_meta_tag :: '@' .ref:id space+ .content:raw ;

toc :: toc#_toc eol+ ;
_toc :: '[TOC]' ;

comment :: '%' '%' raw eol+ ;

command :: '%' [include | breakpage | align | reset | font_size
                | font_color | bg_color | line_spacing
                | extend_ymd_cmd | cmd_error] eol+ ;

cmd_error :: cmd_error:raw ;

include :: include#_include ;
_include :: 'include' space+ .file:raw ;

breakpage :: breakpage#_breakpage ;
_breakpage :: 'breakpage' space* ;

align :: align#_align ;
_align :: 'align' space+ .mode:raw ;

reset :: reset#_reset ;
_reset :: 'reset' space* ;

font_size :: font_size#_font_size ;
_font_size :: 'font-size' space+ .size:int space* .unit:font_size_unit space* ;
font_size_unit :: 'px' | 'mm' | 'cm' | 'in' | 'em' ;

font_color :: font_color#_font_color ;
_font_color :: 'font-color' space+ [font_color_rgb | font_color_name] space* ;
font_color_rgb :: '#'
                  .rgb:[alphanum alphanum alphanum alphanum alphanum alphanum] ;
font_color_name :: .name:id ;

bg_color :: bg_color#_bg_color ;
_bg_color :: 'bg-color' space+ [bg_color_rgb | bg_color_name] space* ;
bg_color_rgb :: '#'
                  .rgb:[alphanum alphanum alphanum alphanum alphanum alphanum] ;
bg_color_name :: .name:id ;

line_spacing :: line_spacing#_line_spacing ;
_line_spacing :: 'line-spacing' space+ .val:line_spacing_val space* ;
line_spacing_val :: int ['.' int]? ;




extend_formated :: exponent | format_cmd | extend_ymd_format ;

formated_raw :: [   any ^ '*' ^ '_' ^ '[' ^ '`' ^ '^' ^ '&'
                  ^ '(' ^ '!' ^ ' * ' ^ ' _ ' ^ ' ` ' ^ ' ( ' ^ ' [ '
                  ^ line_break ^ eol]+ ;

exponent :: exponent#_exponent | format_error:'^' ;
_exponent :: '^' [simple_exp | long_exp] ;
simple_exp :: %[any ^ '('] raw:[any ^ space ^ eol]+ ;
long_exp :: '(' raw:[any ^ ')' ^ eol]+ ')' ;

format_cmd :: format_cmd#_format_cmd | format_error:'&' ;
_format_cmd :: '&' .cmd:id [format_cmd_arg_list | format_cmd_no_arg] ;
format_cmd_arg_list :: '(' format_cmd_arg? [format_cmd_sep format_cmd_arg]* ')' ;
format_cmd_no_arg :: ';' ;
format_cmd_arg :: space* raw:_format_cmd_arg space* ;
_format_cmd_arg :: [any ^ ',' ^ [' '+ ')']]+ ;
format_cmd_sep :: ',' ;

table :: table#_table ;
_table :: false ;

'''

