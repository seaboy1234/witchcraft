
module witchcraft.mixins.constructors;

mixin template WitchcraftConstructor()
{
    import witchcraft;

    import std.algorithm;
    import std.conv;
    import std.meta;
    import std.range;
    import std.string;
    import std.variant;

    static class ConstructorImpl(T, size_t overload) : Constructor
    {
    private:
        alias method = Alias!(__traits(getOverloads, T, "__ctor")[overload]);

    public:
        override Object create(Variant[] arguments...) const
        {

            alias Params = Parameters!method;

            enum invokeString = iota(0, Params.length)
                .map!(i => "arguments[%s].get!(Params[%s])".format(i, i))
                .joiner
                .text;

            mixin("return new T(" ~ invokeString ~ ");");
        }

        @property
        override const(Attribute)[] getAttributes() const
        {
            alias attributes = AliasSeq!(__traits(getAttributes, method));

            auto values = new Attribute[attributes.length];

            foreach(index, attribute; attributes)
            {
                values[index] = new AttributeImpl!attribute;
            }

            return values;
        }

        @property
        override const(Class) getDeclaringClass() const
        {
            return T.classof;
        }

        @property
        override const(TypeInfo) getDeclaringType() const
        {
            return typeid(T);
        }

        override const(Class)[] getParameterClasses() const
        {
            auto parameterClasses = new Class[Parameters!method.length];

            foreach(index, Parameter; Parameters!method)
            {
                static if(__traits(hasMember, Parameter, "classof"))
                {
                    parameterClasses[index] = Parameter.classof;
                }
            }

            return parameterClasses;
        }

        @property
        override const(TypeInfo)[] getParameterTypes() const
        {
            auto parameterTypes = new TypeInfo[Parameters!method.length];

            foreach(index, Parameter; Parameters!method)
            {
                parameterTypes[index] = typeid(Parameter);
            }

            return parameterTypes;
        }

        @property
        override string getProtection() const
        {
            return __traits(getProtection, method);
        }

        @property
        override bool isVarArgs() const
        {
            return variadicFunctionStyle!method != Variadic.no;
        }
    }
}