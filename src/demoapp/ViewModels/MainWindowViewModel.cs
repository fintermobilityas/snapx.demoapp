using System.Reactive;
using ReactiveUI;

namespace demoapp.ViewModels
{
    public class MainWindowViewModel : ViewModelBase
    {
        string _currentVersion;
        string _currentChannel;
        string _currentFeed;
        string _currentApplicationId;
        string _nextVersion;
        string _updateProgressText;
        string _releaseNotes;
        int _updateProgressPercentage;
        bool _isSnapPacked;
        string _snapxVersion;
        string _title;

        bool _viewIsDefault;
        bool _viewIsCheckingForUpdates;
        bool _viewIsApplyingUpdates;
        bool _viewIsUpdateCompleted;

        public string Title
        {
            get => _title;
            set => this.RaiseAndSetIfChanged(ref _title, value);
        }

        public bool IsSnapPacked
        {
            get => _isSnapPacked;
            set => this.RaiseAndSetIfChanged(ref _isSnapPacked, value);
        }

        public string CurrentVersion
        {
            get => _currentVersion;
            set => this.RaiseAndSetIfChanged(ref _currentVersion, value);
        }
        
        public string ReleaseNotes
        {
            get => _releaseNotes;
            set => this.RaiseAndSetIfChanged(ref _releaseNotes, value);
        }

        public string CurrentChannel
        {
            get => _currentChannel;
            set => this.RaiseAndSetIfChanged(ref _currentChannel, value);
        }

        public string CurrentFeed
        {
            get => _currentFeed;
            set => this.RaiseAndSetIfChanged(ref _currentFeed, value);
        }

        public string CurrentApplicationId
        {
            get => _currentApplicationId;
            set => this.RaiseAndSetIfChanged(ref _currentApplicationId, value);
        }

        public string NextVersion
        {
            get => _nextVersion;
            set => this.RaiseAndSetIfChanged(ref _nextVersion, value);
        }

        public string SnapxVersion
        {
            get => _snapxVersion;
            set => this.RaiseAndSetIfChanged(ref _snapxVersion, value);
        }

        public int UpdateProgressPercentage
        {
            get => _updateProgressPercentage;
            set => this.RaiseAndSetIfChanged(ref _updateProgressPercentage, value);
        }
        
        public string UpdateProgressText
        {
            get => _updateProgressText;
            set => this.RaiseAndSetIfChanged(ref _updateProgressText, value);
        }

        public bool ViewIsDefault
        {
            get => _viewIsDefault;
            set => this.RaiseAndSetIfChanged(ref _viewIsDefault, value);
        }

        public bool ViewIsCheckingForUpdates
        {
            get => _viewIsCheckingForUpdates;
            set => this.RaiseAndSetIfChanged(ref _viewIsCheckingForUpdates, value);
        }

        public bool ViewIsApplyingUpdates
        {
            get => _viewIsApplyingUpdates;
            set => this.RaiseAndSetIfChanged(ref _viewIsApplyingUpdates, value);
        }
        
        public bool ViewIsUpdateCompleted
        {
            get => _viewIsUpdateCompleted;
            set => this.RaiseAndSetIfChanged(ref _viewIsUpdateCompleted, value);
        }

        public ReactiveCommand<Unit, Unit> CommandOpenApplicationFolder { get; set; }
        public ReactiveCommand<Unit, Unit> CommandCheckForUpdates { get; set; }
        public ReactiveCommand<Unit, Unit> CommandRestartApplication { get; set; }
        public IAppEnvironment Environment { get; set; }

    }
}
