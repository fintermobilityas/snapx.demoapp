using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Linq.Expressions;

namespace demoapp.Extensions;

[SuppressMessage("ReSharper", "UnusedMember.Global")]
internal static class ReflectionExtensions
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
        ArgumentNullException.ThrowIfNull(expression);
        return BuildMemberName(expression.Body);
    }

    public static string BuildPropertyGetterSyntax<T>(this Expression<Func<T, object>> expression)
    {
        ArgumentNullException.ThrowIfNull(expression);
        return $"get_{expression.BuildMemberName()}";
    }

    public static string BuildPropertySetterSyntax<T>(this Expression<Func<T, object>> expression)
    {
        ArgumentNullException.ThrowIfNull(expression);
        return $"set_{expression.BuildMemberName()}";
    }

    static string BuildMemberName(Expression expression) =>
        expression switch
        {
            null => throw new ArgumentException(ExpressionCannotBeNullMessage),
            // Reference type property or field
            MemberExpression memberExpression => memberExpression.Member.Name,
            // Reference type method
            MethodCallExpression methodCallExpression => methodCallExpression.Method.Name,
            // Property, field of method returning value type
            UnaryExpression unaryExpression => BuildMemberName(unaryExpression),
            _ => throw new ArgumentException(InvalidExpressionMessage)
        };

    static string BuildMemberName(UnaryExpression unaryExpression)
    {
        if (unaryExpression.Operand is MethodCallExpression methodExpression)
        {
            return methodExpression.Method.Name;
        }

        if (unaryExpression.Operand is MemberExpression memberExpression)
        {
            return memberExpression.Member.Name;
        }

        throw new NotSupportedException();
    }
}