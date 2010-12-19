## symbols ##

symbol(s::Latin1String) = symbol(s.data)
symbol(s::UTF8String) = symbol(s.data)
symbol(a::Array{Uint8,1}) =
    ccall(dlsym(JuliaDLHandle,"jl_symbol_n"), Any,
          (Ptr{Uint8}, Int32), a, int32(length(a)))::Symbol
gensym() = ccall(dlsym(JuliaDLHandle,"jl_gensym"), Any, ())::Symbol

(==)(x::Symbol, y::Symbol) = is(x, y)

## expressions ##

expr(hd::Symbol, args...) = Expr(hd, {args...}, Any)
expr(hd::Symbol, args::Array{Any,1}) = Expr(hd, args, Any)
copy(e::Expr) = Expr(e.head, copy(e.args), e.type)

## misc syntax ##

macro eval(x)
    quote eval($expr(:quote,x)) end
end
