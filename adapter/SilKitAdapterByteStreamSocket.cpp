// Copyright (c) Vector Informatik GmbH. All rights reserved.

#include "SilKitAdapterByteStreamSocket.hpp"

#include <thread>
#include <iostream>
#include <chrono>

#include "common/Cli.hpp"
#include "common/Parsing.hpp"
#include "common/ParticipantCreation.hpp"
#include "common/SocketToBytesPubSubAdapter.hpp"

using namespace adapters;
using namespace util;

const std::string adapters::bytestreamArg = "--socket-to-byte-stream";
const std::string adapters::unixBytestreamArg = "--unix-socket-to-byte-stream";
const std::string adapters::defaultParticipantName = "SilKitAdapterByteStreamSocket";

void print_help(bool userRequested = false)
{
    std::cout << "Usage (defaults in curly braces if you omit the switch):" << std::endl
        << "sil-kit-adapter-byte-stream-socket [" << participantNameArg
        << " <participant's name{"<< defaultParticipantName <<"}>]\n"
        "  ["
        << configurationArg
        << " <path to .silkit.yaml or .json configuration file>]\n"
        "  ["
        << regUriArg
        << " silkit://<host{localhost}>:<port{8501}>]\n"
        "  ["
        << logLevelArg
        << " <Trace|Debug|Warn|{Info}|Error|Critical|Off>]\n"
        " [["
        << bytestreamArg
        << "\n"
        << bytes_socket::SocketToBytesPubSubAdapter::printArgumentHelp("<host>:<port>", "    ")
        << " ]]\n"
        << " [["
        << unixBytestreamArg
        << "\n"
        << bytes_socket::SocketToBytesPubSubAdapter::printArgumentHelp("<path to socket identifier>", "    ")
        << " ]]\n"
        "\n"
        "There needs to be at least one "
        << bytestreamArg << " argument. Each socket must be unique.\n"
        "SIL Kit-specific CLI arguments will be overwritten by the config file passed by "
        << configurationArg << ".\n";

    std::cout << "\n"
        "Example:\n"
        "sil-kit-adapter-byte-stream-socket "
        << participantNameArg << " BytestreamAdapter " << bytestreamArg
        << " localhost:12345\n";

    if (!userRequested)
        std::cout << "\n"
        "Pass "
        << helpArg << " to get this message.\n";
};

int main(int argc, char** argv)
{
    if (findArg(argc, argv, helpArg, argv) != NULL)
    {
        print_help(true);
        return CodeSuccess;
    }

    asio::io_context ioContext;
    try
    {
        throwInvalidCliIf(thereAreUnknownArguments(argc, argv, 
            { &bytestreamArg,      &regUriArg,        &logLevelArg,
              &participantNameArg, &configurationArg, &unixBytestreamArg },
            { &helpArg }));

        SilKit::Services::Logging::ILogger* logger;
        SilKit::Services::Orchestration::ILifecycleService* lifecycleService;
        std::promise<void> runningStatePromise;

        std::string participantName = defaultParticipantName;
        const auto participant = CreateParticipant(argc, argv,
            logger, &participantName, &lifecycleService, &runningStatePromise);

        std::vector<std::unique_ptr<bytes_socket::SocketToBytesPubSubAdapter>> transmitters;

        //set to ensure the provided sockets are unique (text-based)
        std::set<std::string> alreadyProvidedSockets;

        unsigned numberOfRequestedAdaptations = 0;

        foreachArgDo(argc, argv, bytestreamArg, [&](char* arg) -> void {
            ++numberOfRequestedAdaptations;
            transmitters.emplace_back(bytes_socket::SocketToBytesPubSubAdapter::parseArgument(arg,
                alreadyProvidedSockets, participantName,
                ioContext, participant.get(), logger, false));
            });

        foreachArgDo(argc, argv, unixBytestreamArg, [&](char* arg) -> void {
            ++numberOfRequestedAdaptations;
            transmitters.emplace_back(bytes_socket::SocketToBytesPubSubAdapter::parseArgument(arg,
                alreadyProvidedSockets, participantName,
                ioContext, participant.get(), logger, true));
            });
        
        if(numberOfRequestedAdaptations == 0)
        {
            logger->Error("No " + bytestreamArg + " argument, exiting.");
            throw InvalidCli();
        }
        auto finalStateFuture = lifecycleService->StartLifecycle();

        std::thread ioContextThread([&]() -> void {
            ioContext.run();
        });

        promptForExit();

        Stop(ioContext, ioContextThread, *logger,
            &runningStatePromise, lifecycleService, &finalStateFuture);
    }
    catch (const SilKit::ConfigurationError& error)
    {
        std::cerr << "Invalid configuration: " << error.what() << std::endl;
        return CodeErrorConfiguration;
    }
    catch (const InvalidCli&)
    {
        print_help();
        std::cerr << std::endl << "Invalid command line arguments." << std::endl;
        return CodeErrorCli;
    }
    catch (const SilKit::SilKitError& error)
    {
        std::cerr << "SIL Kit runtime error: " << error.what() << std::endl;
        return CodeErrorOther;
    }
    catch (const std::exception& error)
    {
        std::cerr << "Something went wrong: " << error.what() << std::endl;
        return CodeErrorOther;
    }

    return CodeSuccess;
}
