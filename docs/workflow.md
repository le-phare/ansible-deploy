```mermaid
stateDiagram-v2
    Setup --> UpdateCode
    UpdateCode --> SymlinkShared
    SymlinkShared --> SetupSymfony
    SetupSymfony --> Symlink
    Symlink --> Cleanup

    state Setup {
        ansistrano_before_setup_tasks_file --> ansistrano_after_setup_tasks_file
    }

    state UpdateCode {
        ansistrano_before_update_code_tasks_file --> ansistrano_after_update_code_tasks_file
    }

    state SymlinkShared {
        ansistrano_before_symlink_shared_tasks_file --> ansistrano_after_symlink_shared_tasks_file
    }

    state SetupSymfony {
       Composer --> Assets
       Assets --> Assetic
       Assetic --> Cache
       Cache --> Doctrine
       Doctrine --> MongoDB
    }

    state Composer {
       ansistrano_symfony_before_composer_tasks_file --> ansistrano_symfony_after_composer_tasks_file
    }

    state Assets {
        ansistrano_symfony_before_assets_tasks_file --> ansistrano_symfony_after_assets_tasks_file
    }

    state Assetic {
        ansistrano_symfony_before_assetic_tasks_file --> ansistrano_symfony_after_assetic_tasks_file
    }

    state Cache {
        ansistrano_symfony_before_cache_tasks_file --> ansistrano_symfony_after_cache_tasks_file
    }

    state Doctrine {
        ansistrano_symfony_before_doctrine_tasks_file --> ansistrano_symfony_after_doctrine_tasks_file
    }

    state ansistrano_symfony_before_doctrine_tasks_file {
        lephare_symfony_before_doctrine_tasks_file --> ansistrano_symfony_after_doctrine_tasks_file
    }

    state lephare_symfony_before_doctrine_tasks_file {
        StopWorkers
    }


    state MongoDB {
        ansistrano_symfony_before_mongodb_tasks_file --> ansistrano_symfony_after_mongodb_tasks_file
    }

    state Symlink {
        ansistrano_before_symlink_tasks_file --> ansistrano_after_symlink_tasks_file
    }

    state Cleanup {
        ansistrano_before_cleanup_tasks_file --> ansistrano_after_cleanup_tasks_file
    }

    state ansistrano_before_symlink_tasks_file {
        lephare_before_symlink_tasks_file
    }

    state lephare_before_symlink_tasks_file {
        PublishAssets --> PreventIndexation
        PreventIndexation --> Secure
        Secure --> Adminer
        Adminer --> Couscous
        Couscous --> Remove files
    }

    state ansistrano_after_symlink_tasks_file {
        CacheTool --> Crontab
        Crontab --> CloudfrontInvalidate
        CloudfrontInvalidate --> RollbarNotify
        RollbarNotify --> SentryNotify
        SentryNotify --> Tideways
        Tideways --> SlackNotify
    }

    state ansistrano_symfony_after_cache_tasks_file {
        SetPermissions
    }
