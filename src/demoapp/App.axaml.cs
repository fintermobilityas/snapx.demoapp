using System;
using System.Diagnostics;
using System.Reflection;
using System.Threading;
using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using Avalonia.ReactiveUI;
using demoapp.ViewModels;
using NLog;
using NLog.Config;
using NLog.Targets;
using Snap.Core;
using Snap.Core.Models;
using Logger = NLog.Logger;
using LogLevel = NLog.LogLevel;

namespace demoapp;

public interface IAppEnvironment
{
    SnapApp SnapApp { get; }
    ISnapUpdateManager UpdateManager { get; }
}

public sealed class AppEnvironment : IAppEnvironment
{
    public SnapApp SnapApp { get; set; }
    public ISnapUpdateManager UpdateManager { get; set; }
}
    
internal sealed class App : Application
{
    static Logger _logger;

    public override void Initialize() => AvaloniaXamlLoader.Load(this);

    public override void OnFrameworkInitializationCompleted()
    {
        base.OnFrameworkInitializationCompleted();

        switch (ApplicationLifetime)
        {
            case IClassicDesktopStyleApplicationLifetime classicDesktopStyleApplicationLifetime:
                classicDesktopStyleApplicationLifetime.MainWindow = new MainWindow();
                return;
            default:
                throw new NotSupportedException($"Unknown application life time: {ApplicationLifetime?.GetType().FullName}");
        }
    }

    static int Main(string[] args)
    {
        ConfigureNlog();
        _logger = LogManager.GetCurrentClassLogger();
        Snapx.EnableNLogLogProvider();

        if (Environment.GetEnvironmentVariable("SNAPX_WAIT_DEBUGGER") == "1")
        {
            var process = Process.GetCurrentProcess();

            while (!Debugger.IsAttached)
            {
                _logger.Debug($"Waiting for debugger to attach... Process id: {process.Id}");
                Thread.Sleep(1000);
            }

            _logger.Debug("Debugger attached.");
        }
            

        _logger.Info($"Process started! Arguments({args.Length}): {string.Join(" ", args)}");
        _logger.Info($"Environment variable 1: TEST={Environment.GetEnvironmentVariable("VAR1")}");
        _logger.Info($"Environment variable 2: TEST={Environment.GetEnvironmentVariable("VAR2")}");

        if (Snapx.ProcessEvents(args))
        {
            return 0;
        }
            
        var snapApp = Snapx.Current;

        if (snapApp != null)
        {
            // Supervisor automatically restarts your application if it crashes.
            // If you need to exit your application the you must invoke Snapx.StopSupervisor() before exiting.
            Snapx.StartSupervisor();
        }
            
        var mainWindowViewModel = new MainWindowViewModel
        {
            ViewIsDefault = true,
            Environment = new AppEnvironment
            {
                SnapApp = snapApp,
                UpdateManager = snapApp == null ? null : new SnapUpdateManager
                {
                    ApplicationId = Guid.NewGuid().ToString("N")
                }
            }
        };

        AppBuilder
            .Configure<App>()
            .UsePlatformDetect()
            .UseReactiveUI()
            .AfterSetup(_ =>
            {
                MainWindow.ViewModel = mainWindowViewModel;
            })
            .StartWithClassicDesktopLifetime(args);

        return 0;
    }

    static void ConfigureNlog()
    {
        var assemblyVersion = typeof(App)
            .Assembly
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?
            .InformationalVersion ?? "0.0.0";

        var layout = $"${{date}} Process id: ${{processid}}, Version: ${{assembly-version:${assemblyVersion}}}, Thread: ${{threadname}}, ${{logger}} - ${{message}} " +
                     "${onexception:EXCEPTION OCCURRED\\:${exception:format=ToString,StackTrace}}";
            
        var config = new LoggingConfiguration();
            
        var fileTarget = new FileTarget("logfile")
        {
            FileName = "demoapp.log",
            Layout = layout
        };
            
        config.AddRule(LogLevel.Trace, LogLevel.Fatal, fileTarget);

        var consoleTarget = new ConsoleTarget("logconsole")
        {
            Layout = layout
        };
            
        config.AddRule(LogLevel.Trace, LogLevel.Fatal, consoleTarget);
            
        if (Debugger.IsAttached)
        {
            var debugTarget = new DebuggerTarget("debug")
            {
                Layout = layout
            };
            config.AddRule(LogLevel.Trace, LogLevel.Fatal, debugTarget);
        }

        LogManager.Configuration = config;
            
        SetNlogLogLevel(LogLevel.Trace);
    }
        
    static void SetNlogLogLevel(LogLevel level)
    {
        if (level == LogLevel.Off)
        {
            LogManager.DisableLogging();
        }
        else
        {
            if (!LogManager.IsLoggingEnabled())
            {
                LogManager.EnableLogging();
            }

            foreach (var rule in LogManager.Configuration.LoggingRules)
            {
                // Iterate over all levels up to and including the target, (re)enabling them.
                for (var i = level.Ordinal; i <= 5; i++)
                {
                    rule.EnableLoggingForLevel(LogLevel.FromOrdinal(i));
                }
            }
        }

        LogManager.ReconfigExistingLoggers();
    }
        
}