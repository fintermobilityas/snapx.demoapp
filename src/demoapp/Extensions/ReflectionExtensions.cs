using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Linq.Expressions;

namespace demoapp.Extensions;

[SuppressMessage("ReSharper", "UnusedMember.Global")]
public static class ReflectionExtensions
{
    const string ExpressionCannotBeNullMessage = "The expression cannot be null";
    const string InvalidExpressionMessage = "Invalid expression";

    public static Type ResolveTypeUsingAssemblyOfT<T>([NotNull] this string typeName)
    {
        ArgumentNullException.ThrowIfNull(typeName);
        return typeName.ResolveType(new[] { typeof(T).Assembly.FullName});
    }
        
    public static Type ResolveType([NotNull] this string typeName, [NotNull] IEnumerable<string> assemblyNames)
    {
        ArgumentNullException.ThrowIfNull(typeName);
        ArgumentNullException.ThrowIfNull(assemblyNames);

        return assemblyNames
            .Select(assemblyName => Type.GetType($"{typeName}, {assemblyName}"))
            .FirstOrDefault(type => type != null) ?? Type.GetType(typeName);
    }
        
    [SuppressMessage("ReSharper", "MemberCanBePrivate.Global")]
    public static string BuildMemberName<T>(this Expression<Func<T, object>> expression)
    {
        return BuildMemberName(expression.Body);
    }

    public static string BuildPropertyGetterSyntax<T>(this Expression<Func<T, object>> expression)
    {
        var propertyName = expression.BuildMemberName();
        return $"get_{propertyName}";
    }

    public static string BuildPropertySetterSyntax<T>(this Expression<Func<T, object>> expression)
    {
        var propertyName = expression.BuildMemberName();
        return $"set_{propertyName}";
    }
    static string BuildMemberName(Expression expression)
    {
        switch (expression)
        {
            case null:
                throw new ArgumentException(ExpressionCannotBeNullMessage);
            case MemberExpression memberExpression:
                // Reference type property or field
                return memberExpression.Member.Name;
            case MethodCallExpression methodCallExpression:
                // Reference type method
                return methodCallExpression.Method.Name;
            case UnaryExpression unaryExpression:
                // Property, field of method returning value type
                return BuildMemberName(unaryExpression);
            default:
                throw new ArgumentException(InvalidExpressionMessage);
        }
    }

    static string BuildMemberName(UnaryExpression unaryExpression)
    {
        if (unaryExpression.Operand is MethodCallExpression methodExpression)
        {
            return methodExpression.Method.Name;
        }

        return ((MemberExpression)unaryExpression.Operand).Member.Name;
    }
}