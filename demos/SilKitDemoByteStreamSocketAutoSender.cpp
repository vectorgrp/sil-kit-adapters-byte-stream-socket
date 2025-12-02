// SPDX-FileCopyrightText: Copyright 2025 Vector Informatik GmbH
// SPDX-License-Identifier: MIT

#include <iostream>
#include <string>
#include <thread>
#include <chrono>

#include "common/Parsing.hpp"
#include "common/Cli.hpp"

#include "silkit/SilKit.hpp"
#include "silkit/config/all.hpp"
#include "silkit/services/pubsub/all.hpp"
#include "silkit/util/serdes/Serialization.hpp"

using namespace adapters;
using namespace util;
using namespace SilKit::Services::PubSub;

constexpr size_t SILKIT_HEADER_SIZE = 4;

void PrintHelp()
{
    std::cout << "Usage (defaults in curly braces if you omit the switch):" << std::endl;
    std::cout << "sil-kit-demo-byte-stream-socket-auto-sender [--name <participant's name{ByteStreamSocketAutoSender}>]\n"
              << "  [--registry-uri silkit://<host{localhost}>:<port{8501}>]\n"
              << "  [--log <Trace|Debug|Warn|{Info}|Error|Critical|Off>]\n"
              << "\n"
              << "Example:\n"
              << "  sil-kit-demo-byte-stream-socket-auto-sender --log Debug\n";
}

int main(int argc, char** argv)
{
    if (findArg(argc, argv, "--help", argv) != nullptr)
    {
        PrintHelp();
        return CodeSuccess;
    }

    const std::string participantName = getArgDefault(argc, argv, participantNameArg, "ByteStreamSocketAutoSender");
    const std::string registryUri = getArgDefault(argc, argv, regUriArg, "silkit://localhost:8501");
    const std::string loglevel = getArgDefault(argc, argv, logLevelArg, "Info");

    const std::string publishTopic = "toSocket";
    const std::string subscribeTopic = "fromSocket";

    try
    {
        const std::string participantConfigurationString =
            R"({ "Logging": { "Sinks": [ { "Type": "Stdout", "Level": ")" + loglevel + R"("} ] } })";

        auto participantConfiguration =
            SilKit::Config::ParticipantConfigurationFromString(participantConfigurationString);

        auto participant = SilKit::CreateParticipant(participantConfiguration, participantName, registryUri);

        auto logger = participant->GetLogger();

        PubSubSpec pubSpec(publishTopic, SilKit::Util::SerDes::MediaTypeData());
        auto dataPublisher = participant->CreateDataPublisher(participantName + "_pub", pubSpec);

        PubSubSpec subSpec(subscribeTopic, SilKit::Util::SerDes::MediaTypeData());
        auto dataSubscriber = participant->CreateDataSubscriber(
            participantName + "_sub", subSpec,
            [&](IDataSubscriber* /*subscriber*/, const DataMessageEvent& dataMessageEvent) {
                auto msgVector = SilKit::Util::ToStdVector(dataMessageEvent.data);
                std::string msg = std::string(msgVector.begin() + SILKIT_HEADER_SIZE, msgVector.end());
                logger->Info("Adapter >> AutoSender: " + msg);
            });

        logger->Info("Press CTRL + C to stop the process...");

        // delay for SIL Kit environment setup
        std::this_thread::sleep_for(std::chrono::seconds(1));

        int msgId = 0;
        while (true)
        {
            std::string msg = "test message " + std::to_string(msgId);
            logger->Info("AutoSender >> Adapter: " + msg);
            
            SilKit::Util::SerDes::Serializer serializer;
            serializer.Serialize(msg);
            dataPublisher->Publish(serializer.ReleaseBuffer());

            std::this_thread::sleep_for(std::chrono::seconds(2));

            ++msgId;
        }
    }
    catch (const SilKit::ConfigurationError& error)
    {
        std::cerr << "[Error] Invalid configuration: " << error.what() << std::endl;
        return CodeErrorConfiguration;
    }
    catch (const std::exception& error)
    {
        std::cerr << "[Error] Something went wrong: " << error.what() << std::endl;
        return CodeErrorOther;
    }

    return CodeSuccess;
}
